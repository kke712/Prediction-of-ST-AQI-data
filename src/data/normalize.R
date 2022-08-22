library(dplyr)

train_list <- readRDS("./data/train_list.rds")
test_list <- readRDS("./data/test_list.rds")

vars <- c("O3", "NO2", "temp", "humidity",
        "SO2", "CO", "PM10", "lat", "log",
        "prec", "windspeed", "winddirection", "vaporpres",
        "Lpres", "Bpres", "hoy", "chours")

train_list_norm <- list()
test_list_norm <- list()

# standardize using train data
for (i in seq_len(length(train_list))) {
    train_scaled <- train_list[[i]][vars] %>%
        scale()
    test_scaled <- test_list[[i]][vars] %>%
        scale(center = attr(train_scaled, "scaled:center"),
            scale = attr(train_scaled, "scaled:scale"))
    train_list_norm[[i]] <- train_list[[i]]
    test_list_norm[[i]] <- test_list[[i]]
    train_list_norm[[i]][vars] <- train_scaled
    test_list_norm[[i]][vars] <- test_scaled
}

saveRDS(train_list_norm, "./data/train_list_norm.rds")
saveRDS(test_list_norm, "./data/test_list_norm.rds")