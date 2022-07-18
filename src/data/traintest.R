library(lubridate)
library(purrr)
library(phylin)
library(dplyr)
library(progress)
library(parallel)

start_date <- ymd_hms("2018-01-01 00:00:00", tz = "Asia/Seoul")

## month: May
month <- 5
myset <- seq(
    from = ymd_hms(paste0("2020-", month, "-01 00:00:00"), tz = "Asia/Seoul"),
    to = ymd_hms(paste0("2020-", month, "-30 00:00:00"), tz = "Asia/Seoul"),
    by = 60^2
)

## sampling
# set.seed(1)
# testind <- sample(myset, 50) %>%
#   purrr::map(~seq(from = .x, by = 60^2, length.out = 12))
# saveRDS(testind, "./data/testind_May.rds")
testind <- readRDS("./data/testind_May.rds")

# load data
airkorea_hourly <- readRDS("./data/airkorea.rds") %>%
    distinct(date, code, .keep_all = TRUE)
kma_hourly <- readRDS("./data/kmadata.rds") %>%
    select(
        datetime, loc, temp, prec, windspeed, winddirection,
        humidity, vaporpres, Lpres, Bpres
    )
observatory_kma <- read.csv("./data/observatory_kma.csv")
observatory_airkorea <- read.csv("./data/observatory_airkorea.csv")
observatory_airkorea <- observatory_airkorea %>%
    select(station, log, lat) %>%
    group_by(station) %>%
    summarise(log = log[1], lat = lat[1]) %>%
    transmute(station = as.character(station), log = log, lat = lat)

# IDW Transformation
idw_transform <- function(x, attname) {
    x <- x %>%
        left_join(observatory_kma, by = c("loc" = "index"))

    reslist <- attname %>%
        purrr::map(~ idw(
            x[[.x]], as.matrix(x[, c("lat", "lon")]),
            as.matrix(observatory_airkorea[, c("lat", "log")])
        )) %>%
        as.data.frame()
    names(reslist) <- attname
    return(
        cbind(
            datetime = x$datetime[1],
            observatory_airkorea[, c("station", "lat", "log")],
            reslist
        )
    )
}

# add kma to train, test
attname <- c(
    "temp", "prec", "windspeed", "winddirection",
    "humidity", "vaporpres", "Lpres", "Bpres"
)
get_kma <- function(start_datetime, end_datetime) {
    kma_filtered <- kma_hourly %>%
        mutate(datetime = ymd_hm(datetime, tz = "Asia/Seoul")) %>%
        dplyr::filter(datetime >= start_datetime &
            datetime <= end_datetime)
    kma_list <- split(kma_filtered, kma_filtered$datetime)
    mini_kma <- kma_list %>%
        purrr::map(~ idw_transform(.x, attname))
    return(mini_kma)
}

# train_airkorea_list
train_test_list <- mclapply(seq_len(length(testind)), function(ind) {
    start_testdate <- testind[[ind]][1]
    end_testdate <- start_testdate + hours(11)
    start_traindate <- start_testdate - weeks(2)

    airkorea_yesterday <- airkorea_hourly %>%
        select(date, code, O3, NO2) %>%
        filter(
            date <= end_testdate - days(1),
            date >= start_traindate - days(1)
        ) %>%
        mutate(date_1d = date + days(1))
    airkorea_today <- airkorea_hourly %>%
        select(-c(O3, NO2)) %>%
        filter(date <= end_testdate, date >= start_traindate)

    mini_kma <- do.call(rbind, get_kma(start_traindate - days(1), end_testdate))

    kma_yesterday <- mini_kma %>%
        select(datetime, station, temp, humidity) %>%
        filter(
            datetime < end_testdate - days(1),
            datetime >= start_traindate - days(1)
        ) %>%
        mutate(date_1d = datetime + days(1)) %>%
        tibble::as_tibble()
    kma_today <- mini_kma %>%
        select(-c(temp, humidity)) %>%
        filter(
            datetime < end_testdate,
            datetime >= start_traindate
        ) %>%
        tibble::as_tibble()

    data_yesterday <- left_join(airkorea_yesterday, kma_yesterday,
        by = c("date_1d", "code" = "station")
    ) %>%
        select(-datetime)
    data_today <- left_join(airkorea_today, kma_today,
        by = c("date" = "datetime", "code" = "station")
    )

    train_data_i <- left_join(data_today, data_yesterday,
        by = c("date" = "date_1d", "code")
    ) %>%
        select(
            date, SO2, CO, PM10, PM25, lat, log, prec, windspeed,
            winddirection, vaporpres, Lpres, Bpres, O3, NO2, temp, humidity
        ) %>%
        filter(date < start_testdate) %>%
        mutate(
            hoy = hour(date),
            chours = as.numeric(date - start_date, units = "hours")
        )

    data_recent <- data_today %>%
        filter(date == start_testdate - hours(1)) %>%
        select(-PM25)
    true_PM25 <- data_today %>%
        filter(date >= start_testdate) %>%
        select(date, PM25)
    test_data_i <- data_yesterday %>%
        filter(date_1d >= start_testdate) %>%
        mutate(date = date_1d) %>%
        select(-date_1d) %>%
        left_join(data_recent, by = "code") %>%
        select(-c("loc", "code", "name", "date.y")) %>%
        mutate(
            hoy = hour(date.x),
            chours = as.numeric(date.x - start_date, units = "hours")
        ) %>%
        left_join(true_PM25, by = c("date.x" = "date"))
    colnames(test_data_i)[1] <- "date"

    train_data_i <- train_data_i %>%
        select(colnames(test_data_i))
    test_data_i$predPM25 <- NA

    return(list(train = train_data_i, test = test_data_i))
}, mc.cores = 8)

train_list <- lapply(train_test_list, function(x) x$train)
test_list <- lapply(train_test_list, function(x) x$test)
saveRDS(train_list, file = "./data/train_list.rds")
saveRDS(test_list, file = "./data/test_list.rds")

# to csv
for (i in seq_len(length(testind))) {
    write.csv(train_list[[i]], paste0("./data/csv/train_", i, ".csv"))
    write.csv(test_list[[i]], paste0("./data/csv/test_", i, ".csv"))
}
