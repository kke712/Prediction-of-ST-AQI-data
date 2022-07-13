## 7th data ##
library(lubridate)
library(purrr)
library(dplyr)
library(randomForest)
library(tictoc)
library(ggplot2)


## data structure - NA 처리 안되어있음 
train_list <- readRDS("~/M/AQI/7th data/data/train_list.rds")
test_list <- readRDS("~/M/AQI/7th data/data/test_list.rds")


## RandomForest for문 시작
for(dd in 1:4){
  train <- train_list[[dd]]
  test <- test_list[[dd]]
  
  ### modeling
  
  colnames(train)
  train <- train[,-1]
  m <- (length(colnames(train))-1)/3 
  
  tic(paste0("randomforest modeling for ",dd))
  rf.fit <- randomForest(PM25~. , data=train, mtry=floor(m), ntree=500, importance=T, na.action=na.omit) # 3시간 37분
  toc()
  # print(rf.fit)
  
  saveRDS(rf.fit,paste0("~/M/AQI/7th data/rf_fit/rf_fit_",dd,".rds"))
  
  
  ## na 따로 저장
  test <- subset(test, select=-c(predPM25)) #predPM25삭제
  
  
  test_na <- test[!complete.cases(test),]
  test_pred <- test[complete.cases(test),]
  
  ## prediction using randomforest modeling
  test_x <- subset(test_pred, select=-c(date,PM25))
  y <- test_pred$PM25
  y_pred <- predict(rf.fit, test_x)
  
  test_pred$predPM25 <- y_pred
  test_na$predPM25 <- NA
  
  test <- rbind(test_pred, test_na)
  
  ## save the result
  saveRDS(test,paste0("~/M/AQI/7th data/result/result_",dd,".rds"))
  
}


