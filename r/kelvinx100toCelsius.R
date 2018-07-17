######### Raster calculation to convert the units from the thermal FLir to celsius
########  Because they come in Kelvin multiplied by 100
#######   CROPS the rasters to ROIS read from the GDB to crop image
########  Reads from standard formating of files, from GEO folder to CEL

#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(raster)
require(rgdal)

###################### DEFINED FUNCTIONS (no need to edit)
#Function Kelvin 100 to raster
fun <-function(x){(x/100)-273.15}

#Function to select the apropriate roi for each trial
# Read the feature class
get_roi <- function(trial_roi) {readOGR(dsn=fgdb,layer=trial_roi)}

#Function kelvinx100toCelsius
kelvinx100toCelsius <- function(imgK,roi) 
{
  tryCatch({
    celsius<-calc(imgK, fun)
    #celsius <- mask(celsius, roi)
    celsius<-crop(celsius, extent(roi), snap="out")
    #Write the tif to disk
    #replacing the suffix of the raster geo -> cel
    out_File= gsub("geo", "cel", rasterName)
    #out_FileCopy= gsub("geo", "cel", rasterCopy) 
    writeRaster(celsius, file=out_File,datatype='FLT4S',format="GTiff",overwrite=FALSE)
    if (copy) writeRaster(celsius, file=out_FileCopy,datatype='FLT4S',format="GTiff",overwrite=FALSE)
    print(paste("saved raster: <<",out_File,">> Succesfully"))
  })
}

######################## DEFINE VARIABLES (Enter your variables)
# #Working directory
wd="G:\\AF\\" #For images, the root folder
setwd(wd)

ext<-".tif"
roi_name<- "__af__roi"
sx<-"geo" #input sufix
#Feature geodatabase to get ROIS
fgdb = "C:\\Dropbox\\data\\AF\\compass\\af_compass\\af_compass.gdb"
#MAtrix of images dates to process
#Beware if there is only one trial, fake another column filling with "-" in the cameras ??NOTE!!
name_file_data <- "C:\\Dropbox\\data\\AF\\nut\\q21__af__dayt.csv"
##Next the location if you want to copy the data somewhere else
copy <- FALSE #check the function if you want to copy !!!!!!!!!!!F#FFFFF#####
copyLocation <- "C:\\Dropbox\\New folder\\temp\\521\\AD\\" 

######################### STARTs SCRIPT (No need to edit)
tryCatch({
  # rasterName<-args[1] # to read from cmd
  data<-read.table(name_file_data, header = TRUE,sep = ",")
  row.names(data)<-data[,1] # name the rows as the date
  dates<- row.names(data)
  #Get the trial names
  data<- data[,2:length(colnames(data))] #Remove 1st column that had the dates
  trials<- colnames(data) #assign them as column names of the dataframe
  #loop for the images to extract
  for (d in dates){ 
    #TODO: put the trial loop outside the date, to be able to call the get_roi just once per trial.
    for (t in trials){
      cam<-data[d,t]
      if (cam != "-"){
        imgLocation =  paste(wd,d,"\\",cam,"\\geo\\",sep="") #Look into geo folder
        name = paste(cam,d,t,sx,ext,sep="")
        rasterName= paste(imgLocation,name,sep="")
        if (copy) {rasterCopy= paste(copyLocation,name,sep="")}#location to copy if needed
        if(file.exists(rasterName)){#if the raster exists
          print(rasterName) #image name
          dir.create(paste(wd,d,"\\",cam,"\\cel\\",sep="")) #create folder for celsius
          r<-raster(rasterName)
          kelvinx100toCelsius(r,get_roi(paste(t,roi_name,sep=""))) #execute script, crop by roi
        }
        else{print(paste(rasterName," Doesn't exists--"))}
      }
    }
  }
})