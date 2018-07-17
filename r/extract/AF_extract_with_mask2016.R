#This script is a copy of the Protocol to evaluate Plant height 
#Authors: Jose Manuel Mendoza Reyes and Lorena Gonzalez Perez
# this vas adapted to extract multispectral data from Aguafria 2016
#Coments specific to make it work in obregón marked as #L#

library (sp)
library (raster)
library(rgdal)
library(data.table)
library(plyr)
library(dplyr)


#L# Fixed parameters that should be edited each time
date<-"160511"

############################## Funciones definidas

### zonalStatsByPlot (Raster extracted by shapefile) and return a raster
zonalStatsByPlot <- function(shp,raster,fun){
#Calculate Function by plot on raster, we get a data frame
shp_fun <- extract(raster,shp,df=TRUE, fun = fun, sp=TRUE) #sp=TRUE appends results to the shp table
#Put the Function label on the generated column
#toString and substitute are nedded to convert from "function" to "character" class
setnames(shp_fun@data, old="layer",new= toString(substitute(fun)))
#Rasterize Function
r_fun <- raster
r_fun <- rasterize(shp_fun, r_fun, field= toString(substitute(fun)))

return(r_fun)
}
############################ Funciones definidas (END)

#Select the work directory wich are the raster file and shp
setwd(choose.dir(getwd(), "Selecciona tu archivo"))

#select the raster file
#L#
rfile<- file.choose(new = FALSE)
raster<- stack(rfile)
#Count bands
numBands <- dim(raster)[3]

#select band X
#raster <- raster [[4]]
#plot(raster)

#Calculate NDVI
NIR <- raster [[4]]
RED <- raster [[2]]
ndvi = (NIR - RED)/(NIR + RED)
plot(ndvi)
#Manipulate values below x ndvi value
#this may replaace the UDF function "soil.mask" directly on a raster
#ndvi_trshld <- ndvi
#ndvi_trshld[ndvi_trshld<=0.65] = NA
#plot(ndvi_trshld)

#select the shapefile (a shp with buffer genereted in Arcgis)
#shp <- shapefile(list.files(pattern = "\\.shp$"))
#L# Select one file interactively
#shpName <- file.choose(new = FALSE)
shpName <- "C:/Dropbox/data/AD/AD-AF/shp/ad_af_bfs_UTM14.shp"
shp <-shapefile(shpName)
#Add colimn with simple numeric ID
shp$ID<-1:nrow(shp)
#plot(shp, add= TRUE)

#Mask ndvi raster against the plots to get histogram
r_ndviPlots <- mask(ndvi, shp)
#plot(r_ndviPlots)
#hist(r_ndviPlots)

#-----------STV filter
#Calculate STANDARD deviation by plot, return as raster
r_sd <- zonalStatsByPlot(shp,r_ndviPlots,fun=sd)
#plot(r_sd)
#Calculate MEAN by plot, return as raster
r_mean <- zonalStatsByPlot(shp,r_ndviPlots,fun=mean)
#plot(r_mean)
#Apply conditional funtion to exclude what is outside 2-SD by plot
lim_sup <- r_mean + r_sd*2
lim_inf <- r_mean - r_sd*2
r_ndviMasked <- overlay(r_ndviPlots, lim_sup, lim_inf,
                fun=function(r,lim_sup,lim_inf){
                  ifelse(r< lim_sup & r> lim_inf, r, NA)})
#-----------STV filter (END)

#-----------quantiles filter
# #Calculate Qs by plot
# shp_Q <- extract(r_ndviPlots,shp,df=TRUE, fun = quantile, sp=TRUE) #sp=TRUE appends results to the shp table
# #Put the Function label on the generated column
# #Rename the column names
# colnames(shp_Q@data)[5:9] <- c("Q0", "Q1", "Q2","Q3","Q4")
# #Rasterize Function and get the interquantile range and limits that define outliers
# r_Q1 <- r_ndviPlots
# r_Q3 <- r_ndviPlots
# r_Q1 <- rasterize(shp_Q, r_Q1, field= "Q1")
# r_Q3 <- rasterize(shp_Q, r_Q3, field= "Q3")
# r_RIC <- r_Q3 - r_Q1
# r_lim_supQ <- r_Q3 + r_RIC * 1.5
# r_lim_infQ <- r_Q1 - r_RIC * 1.5
# 
# maskSupQ <- (r_ndviPlots < r_lim_supQ)
# maskInfQ <- (r_ndviPlots > r_lim_infQ)
# maskQ <- maskSupQ * maskInfQ
# 
# r_ndviPlotsMaskedQ <- mask(r_ndviPlots, maskQ, maskvalue=0)

#-----------quantiles filter (END)

#Save view to pdf
pdf(file=paste("masked ndvi stdv",date," plots.pdf", sep=""))
par(mfrow=c(1,1))
plot(r_ndviMasked)
hist(r_ndviMasked)
dev.off();

#Save to WD
writeRaster(r_ndviMasked, filename= paste(date, "ndvi_maskSTDV.tif"), format = "GTiff")

#Overlap and extract the pixel value in each polygon
Tableclean <- extract(r_ndviPlotsMaskedQ,shp, na.rm=TRUE)


#Calculate the descriptive statistics of the new list without outliers and convert it in a data base

allstats = lapply(Tableclean,summary)
sd = lapply(Tableclean, sd)
n = lapply(Tableclean, length)

#Join all the statistics calculated in one table
desc.stats.t = mapply(c,allstats,sd, n)

# Transpose the matrix
desc.stats <- t(desc.stats.t)


#Convert to data frame
df <- as.data.frame(desc.stats)

# Add the rownames as a new column
setDT(df, keep.rownames = TRUE)[]

#Rename the columns
colnames(df)[1:9]<-c("Plot", "Min", "Q1", "Median", "Mean", "Q3", "Max", "SD", "n")

#Rewrite again the data frame
df<-data.frame(df)

# Average the values using the unique ID (Plot names)
#final.df=aggregate(cbind(Min, Q1, Median, Mean, Q3, Max, SD, n)~Plot,df, mean)

#write the final table
write.csv(df,paste(date,"_ndviMaskedQ.csv", sep=""))
