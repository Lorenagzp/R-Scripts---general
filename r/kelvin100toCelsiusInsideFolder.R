######### Crop images (Tif) in a folder based on a ROI
########  the roi is read from a GDB

############################ Work in progresssssssssssssssssssssssssssssssssssssssssss

#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(raster)
require(rgdal)
library("caTools")

###################### DEFINED FUNCTIONS (no need to edit)

#Function to select the apropriate roi for each trial
# Read the feature class
get_roi <- function(trial_roi) {readOGR(dsn=fgdb,layer=trial_roi)}

#Function Kelvin 100 to raster
fun <-function(x){(x/100)-273.15}

#Function kelvinx100toCelsius
kelvinx100toCelsius <- function(imgK,roi) 
{
  tryCatch({
    celsius<-calc(imgK, fun)
    #celsius <- mask(celsius, roi)
    celsius<-crop(celsius, extent(roi), snap="out")
    return(celsius)
  })
}

######################## DEFINE VARIABLES (Enter your variables)
# #Working directory
wd="C:\\vuelos\\temp\\marcothermal\\150\\" #For images, the root folder
setwd(wd)
## What kind of files to seach
pattern="\\margeo.bsq$"
roi_name<- "mar__ab__roi"
#Feature geodatabase to get ROIS
fgdb = "C:\\Users\\usuario\\Documents\\ArcGIS\\Default.gdb"

#prefix to add to theOutput name of the crop file
pfx <- "cel"

######################### STARTs SCRIPT (No need to edit)

#Error handling try
tryCatch({
  #list all imagery in the folder
  imgs <-list.files(pattern=pattern)
  print(imgs) #for debugging
  #get roi
  #roi <- get_roi(roi_name)
  roi <- readOGR("C:\\vuelos\\temp\\marcothermal\\150", "mar__ab__roi") #Read SHP
  print(paste("roi")) #for debugging

  #loop for the images to crop
  for (i in imgs){
    #Read raster
    r <- raster(i)
    #crop
    r_cr<-kelvinx100toCelsius(r,roi) #execute script, crop by roi
    print(paste("cropped")) #for debugging
    #name for outpul file
    #outFile <- paste0("t",i,"_q21cel")
    outFile <- paste0(pfx,i)
    print("after outfile")
    #Save file
    writeRaster(r_cr, file=outFile,datatype='FLT4S',format="GTiff",overwrite=FALSE)
    #write.ENVI (r_cr, outFile, interleave = "bsq")
    #inform about saving
    print(paste("saved raster:",outFile," Succesfully"))
  }
})