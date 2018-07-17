#Script to stack the Multispectra bands from the Autopano mosaic
#Names should be like:
# m[date][trial]pno-0.tif
# m[date][trial]pno-1.tif
# e.g. m160204bw8pno-1.tif
# The required input is: date and trial and the working directory
#This is assuming the name formatting of the greenplane
#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(raster)
require(rgdal)

#Function multibandStack
multibandStack <- function(imgBasename,wd) 
{
  tryCatch({
    setwd(wd)
    #Input file with bands 1,2,3
    img_basename<-imgBasename
    img_0<-paste(img_basename,'-0.tif',sep = "")
    imported_raster_0=raster(img_0)
    #Input file with bands 4,5,6
    img_1<-paste(img_basename,'-1.tif',sep = "")
    imported_raster_1=raster(img_1)
    #plot(imported_raster_0) #see image just to test
    #stack 6 bands in one pile
    img=stack(list(img_0,img_1)) 
    #Write the tif to disk
    writeRaster(img, file=paste(imgBasename,".tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
  })
}

#Working directory
date ="160129"
trial = "ros"
wd = paste('G:\\AD15_16\\',date,'\\m\\pno',sep="")
img_b<-paste('m',date,trial,'pno',sep="")
multibandStack(img_b,wd)

