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
library(stringr)

#Function multibandStack
multibandStack <- function(imgBasename, wd) 
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
########### START ##########################
#Working directory
wd="G:\\AD15_16\\160525\\m\\rfl"
setwd(wd)

imgFilesList <-list.files(pattern="\\.tif$")
##Next the names of the images, collapse to get one entry per pair(-0.tif and -1.tif)
#imgsPairNames <- unique(str_extract(imgFilesList, "TTC[:digit:]{5}")) #For individual frames
imgsPairNames <- unique(str_extract(imgFilesList, ".{0,8}")) #For mosaics {0,13}
## Sets the pattern of name in files to be stacked
for (i in imgsPairNames){
  print(paste("Image:",i))
  multibandStack(i, wd) 
}
paste(print("Finished merging",toString(length(imgsPairNames)),"images"))
