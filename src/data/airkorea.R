library(dplyr)
library(readxl)

files <- list()
i <- 1
for (file in list.files("./data/airkorea")) {
    files[[i]] <- readxl::read_xlsx(paste0("./data/airkorea/", file))
    i <- i + 1
}

airkorea <- do.call(rbind, files) %>%
    dplyr::select(지역, 측정소코드, 측정소명, 측정일시, SO2, CO, O3, NO2, PM10, PM25) %>%
    dplyr::rename(loc = 지역, code = 측정소코드, name = 측정소명, date = 측정일시) %>%
    dplyr::mutate(date = as.POSIXct(as.character(date),
        format = "%Y%m%d%H", tz = "Asia/Seoul")) %>%
    dplyr::arrange(date)

saveRDS(airkorea, "./data/airkorea.rds")
