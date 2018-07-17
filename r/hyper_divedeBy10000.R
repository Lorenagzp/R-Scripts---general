## Script to extract values from NDVI imagery inside a (GSA: greenseeker area) ROI, 
## get the mean value of the top 5%. after removing the values < 0.3
## The ROI is read from a GDB, and any feature with attribute area = "FR" is ignored.
## 
#
## No data quality check is implemented yet
## Lorena 2018

#Special comments
#.# this is very specific to this data
#!# Error code or work in progress

####################################################################################
##################################   Libraries
####################################################################################
library(plyr)
library (raster)
library(rgdal)
library(reshape2)

####################################################################################
##################################   Functions
####################################################################################

###########Function to execute the top 5% mean value. Saves PDF with plots on default working directory

#Function divide by 10000
fun <-function(x){(x/10000)}

# divide by 10000
divide10000 <- function(img) {
  img2 <- celsius<-calc(img, fun)
    return(img2)
}
# Choose file interactively | *tif file
chooseTif <- function() {
  choose.files(default = "", caption = "Selecciona la imagen",
                  multi = FALSE, filters = matrix(c("tif", "*.tif")),
                  index = nrow(Filters))}


####################################################################################
##################################   SCRIPT
####################################################################################

#Base Working directory
baseDir <- file.path("C:","Dropbox (RSG)","data","AF","compass", fsep = .Platform$file.sep)
setwd(baseDir)

##Image to work ok
i <- chooseTif() #Opens select file dialog
img <- stack(i)

#Call function to execute task
imgH<- divide10000(img)

#Output filename, same as input, add a "_"
out_File <- paste0(tools::file_path_sans_ext(i),"_.tif")

#Write file , same folder as input
writeRaster(imgH, file=out_File,datatype='FLT4S',format="GTiff",overwrite=FALSE)



