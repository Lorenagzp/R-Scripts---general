#This procedure use the raster file and shapefile_buffer file to extract the mean pixeles values without outliers into a CSV file 
#Author: Jose Manuel Mendoza Reyes
library (sp)
library (raster)
library(rgdal)

#Select the work directory wich are the raster file and shp
setwd(choose.dir(getwd(), "Selecciona tu archivo"))

#select the raster file (NDVI or thermal mosaic)
raster <-raster(list.files(pattern = "\\.tif$"))
#select the shapefile (a shp with buffer genereted in Arcgis)
shp <- shapefile(list.files(pattern = "\\.shp$"))

#plot(raster)
#plot(shp, add= TRUE)

#Set the name of the outut csv table
name<-list.files(pattern = "\\.shp$")
name<-gsub(".shp", "", name)


#Overlap and extract the pixel value in each polygon
pixelval <- extract(raster,shp)


#Add the plot name to the pixel value list
names(pixelval)<- shp$Name

#check the list
#str(pixelval)

#function to eliminate soil pixels or high temperature values
#NDVI
soil.mask <- function(p){
  p.1 = subset(p,p >0.39)
  return(p.1)
}
#TEMPERATURA
# soil.mask <- function(p){
#   p.1 = subset(p,p <6691)
#   return(p.1)
# }

#Apply the mask to the list
massk <- lapply(pixelval,soil.mask)


#function to calculate and eliminate outliers
outliers <- function(dat){
n=2
a=median(dat)
b=sd(dat)
limitesuperior=(a+n*b)
limiteinferior=(a-n*b)
dat1= subset(dat,dat <= limitesuperior & dat >= limiteinferior)
return(dat1)
}

#extract the outliers
f.t = lapply(massk,outliers)


str(f.t)
#Calculate the mean of the new list without outliers and convert it in a data base
output.table = lapply(f.t,mean)
output.table<-data.frame(names(output.table), unlist(output.table))

#add the name of the columns
colnames(output.table)<-c("Plot", "mean_")

#this step is to average rows with the same name (double plots and bordos)
csv=aggregate(mean_ ~ Plot, output.table, mean)


#write the final table
write.csv(csv,paste(name,"_final.csv", sep=""), row.names=FALSE)



