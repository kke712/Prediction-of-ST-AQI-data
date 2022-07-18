####################################################################
########Generate train_1.csv, test_1.csv file for simulation########
####################################################################

library(spacetime)
library(FRK)
library(INLA)

######### download from https://drive.google.com/file/d/1o0-Qfhy0Q3eFamWOsYDjhtjOnMT1436Z/view?usp=sharing
coordinate_dat <- read.csv("coordinate.csv") ##Use 30 stations of the true stations in simulation 

######### download from https://drive.google.com/file/d/1Lrrwrq_USoNls3lExFmAK72bqKyFwoqG/view?usp=sharing
load("results_for_simulation.Rdata") ##Use the results of the real data analysis

#### generate train_1.csv 
time_seq <- seq(from = lubridate::ymd_hm('2020-05-25 06:00',tz="Asia/Seoul"),to = lubridate::ymd_hm('2020-05-29 05:00',tz="Asia/Seoul"),by='hour')
num_station <- nrow(coordinate_dat)
start_date <- ymd_hms("2018-01-01 00:00:00", tz = 'Asia/Seoul')

data_train <- data.frame(X = 1:(length(time_seq)*num_station), date = rep(as.character(time_seq), num_station), O3 = runif(length(time_seq)*num_station,0,0.1),
                         NO2 = runif(length(time_seq)*num_station,0,0.03), temp = runif(length(time_seq)*num_station,14,40),
                         humidity = runif(length(time_seq)*num_station,60,100), SO2 = runif(length(time_seq)*num_station,0,0.01), 
                         CO = runif(length(time_seq)*num_station,0,1), PM10 = runif(length(time_seq)*num_station,10,60),
                         lat = rep(coordinate_dat$lat, each = length(time_seq)), log = rep(coordinate_dat$log, each = length(time_seq)),
                         prec = runif(length(time_seq)*num_station,0,0.3), windspeed = runif(length(time_seq)*num_station,0,3), winddirection = runif(length(time_seq)*num_station,100,300),
                         vaporpres = runif(length(time_seq)*num_station,12,30), Lpres = runif(length(time_seq)*num_station,930,1013), Bpres = runif(length(time_seq)*num_station,1006,1016))

data_train$hoy <- rep(hour(time_seq), num_station)
data_train$chours <- rep(as.numeric(time_seq - start_date, units="hours"), num_station)
  

data_train2 <- data_train[,-1]

data_train2$date <- as.POSIXct(data_train2$date)

data_train2$t <- data_train2$chours - 20766 + 1

STObj0 <- stConstruct(x = data_train2[, c("log", "lat", "date", "t")], space = c("log", "lat"), time = "date")

BAUs <- predict(S, newdata = STObj0, obs_fs = FALSE)

fit_value <- over(STObj0, BAUs)$mu

data_train$PM25 <- predict(ols.fit, data_train2) + fit_value ##use the results of the real data analysis

write.csv(data_train, file = "train_1.csv")


#### generate test_1.csv
time_seq <- seq(from = lubridate::ymd_hm('2020-05-29 06:00',tz="Asia/Seoul"),to = lubridate::ymd_hm('2020-05-29 10:00',tz="Asia/Seoul"),by='hour')
data_test <-  data.frame(X = 1:(length(time_seq)*num_station), date = rep(as.character(time_seq), num_station), O3 = runif(length(time_seq)*num_station,0,0.1),
                         NO2 = runif(length(time_seq)*num_station,0,0.03), temp = runif(length(time_seq)*num_station,14,40),
                         humidity = runif(length(time_seq)*num_station,60,100), SO2 = runif(length(time_seq)*num_station,0,0.01), 
                         CO = runif(length(time_seq)*num_station,0,1), PM10 = runif(length(time_seq)*num_station,10,60),
                         lat = rep(coordinate_dat$lat, each = length(time_seq)), log = rep(coordinate_dat$log, each = length(time_seq)),
                         prec = runif(length(time_seq)*num_station,0,0.3), windspeed = runif(length(time_seq)*num_station,0,3), winddirection = runif(length(time_seq)*num_station,100,300),
                         vaporpres = runif(length(time_seq)*num_station,12,30), Lpres = runif(length(time_seq)*num_station,930,1013), Bpres = runif(length(time_seq)*num_station,1006,1016))

data_test$hoy <- rep(hour(time_seq), num_station)
data_test$chours <- rep(as.numeric(time_seq - start_date, units="hours"), num_station)
data_test$PM25 <- NA ##true PM25; but in simulation data, put NA.
data_test$predPM25 <- NA

write.csv(data_test, file = "test_1.csv")
