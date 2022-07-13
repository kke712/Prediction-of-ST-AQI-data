### Figure for paper about AQI ###
install.packages("lubridate")


## library
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)
library(Metrics)

# bring result of each method
result <- list()

load("C://Users//Miru//Desktop//AQI_server//M//AQI//final result for paper//descriptive//result.v2")

ds <- data_test
rf <- readRDS("C://Users//Miru//Desktop//AQI_server//M//AQI//final result for paper//randomforest//result//result_list.rds")
nn <- readRDS("C://Users//Miru//Desktop//AQI_server//M//AQI//final result for paper//neural networks model//neural_networks_result.rds")

# is.list(ds)
# is.list(rf)
# is.list(nn)


##################################################################
## data structure reconstruction for figure
# ds, rf, nn for + 1h / + 3h / + 6h 
ds_1 <- c()
ds_3 <- c()
ds_6 <- c()
rf_1 <- c()
rf_3 <- c()
rf_6 <- c()
nn_1 <- c()
nn_3 <- c()
nn_6 <- c()


for(dd in 1:50){
  subds <- ds[[dd]]
  subrf <- rf[[dd]]
  subnn <- nn[[dd]]
  
  h_1 <- range(subds$date)[1] # + 1h
  h_3 <- h_1 + hours(2)         # + 3h
  h_6 <- h_1 + hours(5)         # + 6h
  
  # for ds
  h <- subds %>% filter(date==h_1) %>% select(date, PM25, predPM25)
  hh <- subds %>% filter(date==h_3) %>% select(date, PM25, predPM25)
  hhh <- subds %>% filter(date==h_6) %>% select(date, PM25, predPM25)
  
  ds_1 <- rbind(ds_1, h)
  ds_3 <- rbind(ds_3, hh)
  ds_6 <- rbind(ds_6, hhh)
  
  #for rf
  rm(list=c("h", "hh", "hhh"))
  
  h <- subrf %>% filter(date==h_1) %>% select(date, PM25, predPM25)
  hh <- subrf %>% filter(date==h_3) %>% select(date, PM25, predPM25)
  hhh <- subrf %>% filter(date==h_6) %>% select(date, PM25, predPM25)
  
  rf_1 <- rbind(rf_1, h)
  rf_3 <- rbind(rf_3, hh)
  rf_6 <- rbind(rf_6, hhh)
  
  #for nn
  rm(list=c("h", "hh", "hhh"))
  
  nn_1 <- rbind(nn_1, subnn %>% filter(date==h_1)) 
  nn_3 <- rbind(nn_3, subnn %>% filter(date==h_3))
  nn_6 <- rbind(nn_6, subnn %>% filter(date==h_6))
  
}

ds_1 <- na.omit(ds_1)
ds_3 <- na.omit(ds_3)
ds_6 <- na.omit(ds_6)

rf_1 <- na.omit(rf_1)
rf_3 <- na.omit(rf_3)
rf_6 <- na.omit(rf_6)

nn_1 <- na.omit(nn_1)
nn_3 <- na.omit(nn_3)
nn_6 <- na.omit(nn_6)

colnames(nn_1)[3] <- "predPM25"
colnames(nn_3)[3] <- "predPM25"
colnames(nn_6)[3] <- "predPM25"


#########################################################################################
### Fig 1
# x : prediction / y : real value / y=x line
layout(matrix(c(1:9), 3,3, byrow=T))
layout.show(9)

plot(PM25~predPM25,data=ds_1, xlab="prediction using ST-model", ylab="real value", main="+ 1h")
abline(a=0, b=1)

plot(PM25~predPM25,data=ds_3, xlab="prediction using ST-model", ylab="real value", main="+ 3h")
abline(a=0, b=1)

plot(PM25~predPM25,data=ds_6, xlab="prediction using ST-model", ylab="real value", main="+ 6h")
abline(a=0, b=1)

##nn
plot(PM25~predPM25,data=nn_1, xlab="prediction using NN model", ylab="real value", main="+ 1h")
abline(a=0, b=1)

plot(PM25~predPM25,data=nn_3, xlab="prediction using NN model", ylab="real value", main="+ 3h")
abline(a=0, b=1)

plot(PM25~predPM25,data=nn_6, xlab="prediction using NN model", ylab="real value", main="+ 6h")
abline(a=0, b=1)


#rf
plot(PM25~predPM25,data=rf_1, xlab="prediction using RF", ylab="real value", main="+ 1h")
abline(a=0, b=1)

plot(PM25~predPM25,data=rf_3, xlab="prediction using RF", ylab="real value", main="+ 3h")
abline(a=0, b=1)

plot(PM25~predPM25,data=rf_6, xlab="prediction using RF", ylab="real value", main="+ 6h")
abline(a=0, b=1)






#########################################################################################
### Fig 2
# RMSE boxplot 


ds1_rmse <- ds_1 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))
ds3_rmse <- ds_3 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))
ds6_rmse <- ds_6 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))

rf1_rmse <- rf_1 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))
rf3_rmse <- rf_3 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))
rf6_rmse <- rf_6 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))

nn1_rmse <- nn_1 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))
nn3_rmse <- nn_3 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))
nn6_rmse <- nn_6 %>% group_by(date) %>% summarise(RMSE = rmse(PM25,predPM25))


RMSE1 <- c()
RMSE2 <- c()
RMSE3 <- c()

RMSE1$model <- c(rep("ST",50),rep("NN",50),rep("RF",50))
RMSE1$rmse <- c(ds1_rmse$RMSE,  nn1_rmse$RMSE, rf1_rmse$RMSE)
RMSE2$model <- c(rep("ST",50),rep("NN",50),rep("RF",50))
RMSE2$rmse <- c(ds3_rmse$RMSE, nn3_rmse$RMSE, rf3_rmse$RMSE)
RMSE3$model <- c(rep("ST",50),rep("NN",50),rep("RF",50))
RMSE3$rmse <- c(ds6_rmse$RMSE, nn6_rmse$RMSE, rf6_rmse$RMSE)




layout(matrix(c(1:3), 1,3, byrow=T))
layout.show(3)


RMSE1$model <- factor(RMSE1$model, levels=c("ST","NN","RF"))
RMSE2$model <- factor(RMSE1$model, levels=c("ST","NN","RF"))
RMSE3$model <- factor(RMSE1$model, levels=c("ST","NN","RF"))

boxplot(rmse~model, data=RMSE1, ylab="RMSE", main="+ 1h", ylim=c(0,25))
boxplot(rmse~model, data=RMSE2, ylab="RMSE", main="+ 3h", ylim=c(0,25))
boxplot(rmse~model, data=RMSE3, ylab="RMSE", main="+ 6h", ylim=c(0,27))

#########################################################################################
### Table 1
# RMSE table
quantile(ds1_rmse$RMSE, c(0.5,0.75))
quantile(ds3_rmse$RMSE, c(0.5,0.75))
quantile(ds6_rmse$RMSE, c(0.5,0.75))


quantile(rf1_rmse$RMSE, c(0.5,0.75))
quantile(rf3_rmse$RMSE, c(0.5,0.75))
quantile(rf6_rmse$RMSE, c(0.5,0.75))


quantile(nn1_rmse$RMSE, c(0.5,0.75))
quantile(nn3_rmse$RMSE, c(0.5,0.75))
quantile(nn6_rmse$RMSE, c(0.5,0.75))


#########################################################################################
### Table 2
# classification problem / recall plot
# PM25<16 ; 1.good / PM25<36 ; 2.normal / PM25<76 ; 3.bad / else ; 4.very bad

mclass <- function(x){
  a <- c()
  for(i in 1:length(x)){
    if(x[i]<16){
      a[i] <- "1.good"
    } else if(x[i]<36){
      a[i] <- "2.normal"
    } else if(x[i]<76){
      a[i] <- "3. bad"
    } else {
      a[i] <- "4. very bad"
    }
  }
  
  return(a)
}

mclass(ds_1$PM25)

ds_1 <- ds_1 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))
ds_3 <- ds_3 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))
ds_6 <- ds_6 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))

rf_1 <- rf_1 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))
rf_3 <- rf_3 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))
rf_6 <- rf_6 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))

nn_1 <- nn_1 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))
nn_3 <- nn_3 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))
nn_6 <- nn_6 %>% mutate(real=mclass(PM25), pred=mclass(predPM25), class=ifelse(real==pred, "O","X"))







getprob <- function(x){
  total <- x %>% count(real)
  correct <- x %>% filter(class=="O") %>% count(real)
  uncorrect <- x %>% filter(class=="X") %>% count(real)
  
  total <- merge(total, correct, by="real", all=T)
  total <- merge(total, uncorrect, by="real", all=T)
  
  colnames(total) <- c("class","total","correct","uncorrect")
  
  total[is.na(total)] <- 0
  
  total$positive <- total$correct/total$total
  total$negative <- total$uncorrect/total$total
  
  
  return(total)
}

ds1p <- getprob(ds_1)
ds2p <- getprob(ds_3)
ds3p <- getprob(ds_6)

rf1p <- getprob(rf_1)
rf2p <- getprob(rf_3)
rf3p <- getprob(rf_6)

nn1p <- getprob(nn_1)
nn2p <- getprob(nn_3)
nn3p <- getprob(nn_6)


ds1p
ds2p
ds3p

rf1p
rf2p
rf3p 

nn1p 
nn2p 
nn3p 

#########################################################################################
### Table 3
# classification problem / F1-score
# 

# ds doesn't have any very bad category So, it's matrix is a 4 by 3 matrix.
a <- table(ds_1$real, ds_1$pred)

tp <- c()
fp <- c()
fn <- c()



dim(table(ds_1$real, ds_1$pred))
dim(table(ds_3$real, ds_3$pred))
dim(table(ds_6$real, ds_6$pred))

dim(table(rf_1$real, rf_1$pred))
dim(table(rf_3$real, rf_3$pred))
dim(table(rf_6$real, rf_6$pred))

dim(table(nn_1$real, nn_1$pred))
dim(table(nn_3$real, nn_3$pred))
dim(table(nn_6$real, nn_6$pred))

# 4 by 3 
fscore <- function(x){
  a <- table(x$real, x$pred)
  
  tp <- c()
  fp <- c()
  fn <- c()
  
  for(i in 1:3){ 
    
    tp[i] <- a[i,i]
    fn[i] <- sum(a[i,]) - a[i,i]
    fp[i] <- sum(a[,i]) - a[i,i]
  }
  
  tp[4] <- 0
  fn[4] <- sum(a[4,])
  fp[4] <- 0
  
  
  f <- 2*tp/(2*tp+fp+fn)
  
  return(f)
}

# 4 by 4
fscore2 <- function(x){
  a <- table(x$real, x$pred)
  
  tp <- c()
  fp <- c()
  fn <- c()
  
  for(i in 1:4){ 
    
    tp[i] <- a[i,i]
    fn[i] <- sum(a[i,]) - a[i,i]
    fp[i] <- sum(a[,i]) - a[i,i]
    
  }
  
  f <- 2*tp/(2*tp+fp+fn)
  
  return(f)
}


get.fscore <- function(x){
  b <- dim(table(x$real, x$pred))
  
  if(b[2]==4){
    f <- fscore2(x)
  } else { f <- fscore(x) }
  
  return(f)
}

get.fscore(ds_1)
get.fscore(ds_3)
get.fscore(ds_6)

get.fscore(rf_1)
get.fscore(rf_3)
get.fscore(rf_6)

get.fscore(nn_1)
get.fscore(nn_3)
get.fscore(nn_6)


