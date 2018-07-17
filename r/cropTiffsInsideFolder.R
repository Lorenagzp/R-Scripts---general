######### Crop images (Tif) in a folder based on a ROI
########  the roi is read from a GDB

#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(raster)
require(rgdal)

###################### DEFINED FUNCTIONS (no need to edit)

#Function to select the apropriate roi for each trial
# Read the feature class
get_roi <- function(trial_roi) {readOGR(dsn=fgdb,layer=trial_roi)}

######################## DEFINE VARIABLES (Enter your variables)
# #Working directory
wd="C:\\Dropbox\\New folder\\temp\\Franz\\AE\\" #For images, the root folder
setwd(wd)
## What kind of files to seach
pattern="\\.tif$"
roi_name<- "d30__ae__roi"
#Feature geodatabase to get ROIS
fgdb = "C:\\Dropbox\\data\\AE\\nut\\ae_nut.gdb"
#prefix to add to theOutput name of the crop file
pfx <- "crp_"

######################### STARTs SCRIPT (No need to edit)

#Error handling try
tryCatch({
  #list all imagery in the folder
  imgs <-list.files(pattern=pattern)
  print(imgs) #for debugging
  #get roi
  roi <- get_roi(roi_name)
  print(paste("roi")) #for debugging

  #loop for the images to crop
  for (i in imgs){
    #Read raster
    r <- raster(i)
    #crop
    r_cr<-crop(r, extent(roi), snap="out") #execute script, crop by roi
    print(paste("cropped")) #for debugging
    #name for outpul file
    #outFile <- paste0("t",i,"_q21cel")
    outFile <- paste0(pfx,i)
    #Save file
    writeRaster(r_cr, file=outFile,datatype='FLT4S',format="GTiff",overwrite=FALSE)
    #inform about saving
    print(paste("saved raster:",outFile," Succesfully"))
  }
})