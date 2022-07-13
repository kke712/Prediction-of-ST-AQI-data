##################Random Effects with Spatio-Temporal Basis Functions##################

library(dplyr)
library(spacetime)
library(FRK)
library(INLA)
library(foreach)
library(doParallel)



st_model_analysis <- function(i){
  
  data_train <- read.csv(paste0("csv/train_", i, ".csv"))
  data_test <- read.csv(paste0("csv/test_", i, ".csv"))
  
  data_train <- data_train[,-1]
  data_test <- data_test[,-1]
  
  data_train$date <- as.POSIXct(data_train$date)
  data_test$date <- as.POSIXct(data_test$date)
  
  data_train$t <- data_train$chours - min(data_train$chours) + 1
  data_test$t <- data_test$chours - min(data_train$chours) + 1
  
  data_train <- data_train[!(is.na(data_train$PM25)),]

  data_test <- data_test[-which(is.na(data_test$log)==T),]
  
  ols.fit <- lm(PM25 ~ ., data = data_train[,-c(1,ncol(data_train))])
  
  data_test2 <- data_test[,-c(which(colnames(data_test) == "PM25"), which(colnames(data_test) == "predPM25"))] 
  
  data_train2 <- (data_train %>% filter(date == max(data_train$date)))[,c("lat", "log", "PM25")]
  
  data_test2 <- left_join(data_test2, data_train2, by = c("lat", "log"))
  
  data_train <- na.omit(rbind(data_train, data_test2))
  
  data_train$residual <- data_train$PM25 - predict(ols.fit, data_train)
  
  data_train <- data_train[,-which(colnames(data_train) == "PM25")]
  
  STObj <- stConstruct(x = data_train[,c("log", "lat", "date", "residual")], space = c("log", "lat"), time = "date")

  grid_BAUs <- auto_BAUs(manifold = STplane(), type = "grid", data = STObj, cellsize = c(0.2, 0.2, 1), tunit = "hours")
  
  G_spatial <- auto_basis(manifold = plane(), data = as(STObj, "Spatial"), nres = 2, type = "bisquare", regular = 0) #multi-resolution #irregular

  G_temporal <- local_basis(manifold = real_line(), type = "Gaussian", loc = matrix(seq(1, max(data_test$t) + 10, by = 10)), scale = rep(7, length(matrix(seq(1, max(data_test$t) + 10, by = 10))))) ##aperture parameter = 7
  
  G <- TensorP(G_spatial, G_temporal)
  
  STObj$std <- 1
  
  f <- residual ~ 1
  
  S <- FRK(f = f, data = list(STObj), BAUs = grid_BAUs, basis = G, n_EM = 6)

  STObj0 <- stConstruct(x = data_test[, c("log", "lat", "date", "t")], space = c("log", "lat"), time = "date")
  
  BAUs <- predict(S, newdata = STObj0, obs_fs = FALSE)
  
  fit_value <- over(STObj0, BAUs)$mu
  
  data_test$predPM25 <- predict(ols.fit, data_test) + fit_value
  
  save(data_test, file = paste0("result_res6.", i))
  
  print(i)
}
  
  
numCores <- 5

mycluster <- makeCluster(numCores)
registerDoParallel(mycluster)

foreach(i = 1:50, .packages = c( "dplyr", "FRK", "spacetime")) %dopar% {st_model_analysis(i)}
