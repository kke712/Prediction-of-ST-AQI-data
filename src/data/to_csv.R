train_list <- readRDS("./data/train_list_norm.rds")
test_list <- readRDS("./data/test_list_norm.rds")

# to csv
for (i in seq_len(length(test_list))) {
    write.csv(train_list[[i]], paste0("./data/csv/train_", i, ".csv"))
    write.csv(test_list[[i]], paste0("./data/csv/test_", i, ".csv"))
}
