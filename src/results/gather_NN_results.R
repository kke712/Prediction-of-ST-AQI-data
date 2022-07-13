library(dplyr)

datapath <- "./results/NN/"

kw_list <- list()
for (i in 1:50) {
    kw_list[[i]] <- read.csv(paste0(datapath, "pred_", i, ".csv")) %>%
        transmute(date = date, PM25 = PM25, pred = predPM25)
}
saveRDS(kw_list, file = "./results/NN.rds")
