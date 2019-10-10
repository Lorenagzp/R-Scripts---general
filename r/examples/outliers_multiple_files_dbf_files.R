library(RODBC)
library(xlsx)
library(foreign)
################# EDIT#########################
setwd("C:/Dropbox/data/AD/AD_nut/data/extracted1.5mbuffervsGS")
path = "C:/Dropbox/data/AD/AD_nut/data/extracted1.5mbuffervsGS"
path
dir()
file.names <- dir(path, pattern =".dbf")
for(i in 1:length(file.names)){
  dat<- read.dbf(file.names[i])
  dat<- as.data.frame(dat)
  a<-unname(quantile(dat$id, c(0.975))) ##ID field
  b<-unname(quantile(dat$id, c(0.025)))
  dat1<-subset(dat,dat$id<= a & dat$id >= b)
  archivo <- paste("C:/Dropbox/data/AD/AD_nut/data/extracted1.5mbuffervsGS/no_outliers/",file.names[i],sep = "")
  write.dbf(dat1,file=archivo)
  print(i)
}