############# Get average of solar radiation from DAvis metheorologial station in CENEB obregon, it is every 10 minutes and gives the average in W/m2

#Library
library(plyr)

#####Script

##read the data
infile <- choose.files(default = file.path("C:","Dropbox","data", fsep = .Platform$file.sep), caption = "Select AMS data")
dat = read.csv(infile, stringsAsFactors = FALSE)
##Get path and set WD
setwd(normalizePath(dirname(infile)))
##Get the solar radiation
dat_rad <- dat[,c(1,2,3,4,6,26)] 
##Remove the nodata represented with -9999
dat_rad <- dat_rad[which(!(dat_rad$SolarRad %in% "-9999")), ]
##Get the mean per day
mean_solar_rad <- ddply(dat_rad, .(Anio,Mes,Dia), summarize, 
                 "w/m2" = mean(SolarRad))
##Save data to file in the same folder as input file
write.csv(mean_solar_rad,"mean_solar_rad.csv", row.names=FALSE)
print(paste("saved file","mean_solar_rad.csv"," to",getwd()))
