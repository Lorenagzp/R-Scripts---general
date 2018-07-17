####
# it is used to stack in one file the individual bands from the sequoia ( for COMPASS)
# It searches in the structure of the Pix4D results folders OR you can set to work on the base directory

#0. First step : load packages
#install.packages(c("rgdal","raster"))
#require(raster)
#require(rgdal) #it is called in the functions file

######################## DEFINE VARIABLES (Enter your variables)
# #Working directory
wd=  choose.dir(default = "", caption = "Select base working directory for the imagery")
setwd(wd)
sprintf("Wd: %s",wd)

#Choose file list as date | trial1 | trial2...(our standard format)
listDates <-   choose.files(default = "", caption = "Selecciona la matriz de nombres y fechas de archivos a procesar",
                            multi = FALSE, filters = matrix(c("csv", "*.csv")),
                            index = nrow(Filters))

#choose shapefile directory. The name of the ROI is expected to be like: q21__af__roi where q21 is the 3 char id for the trial, af is the cycle id 
shpFolder=  choose.dir(default = "", caption = "Select the folder where the shapefiles are (Polygon ROIs to crop imagery)")
sprintf("shpF: %s",shpFolder)

#trial <-"coc" #this will be selected from the matrix
#cam <- "q" this will be selected from the matrix
ext <- ".tif" #This is assumed
cycle <- "af" #code for the cycle. af is 2017-2018
if_crop <- TRUE #tell if the imagery should be cropped

################### Functions
source(file.path("C:","Dropbox","Software","Scripts","r","functions_ImgProcessing.R", fsep = .Platform$file.sep))

data############### Script
tryCatch({
  data<-read.table(listDates, header = TRUE,sep = ",") #get the data in the csv
  row.names(data)<-data[,1] # name the rows as the date
  dates<- row.names(data)
  #Get the trial names
  data<- data[,2:length(colnames(data))] #Remove 1st column that had the dates
  trials<- colnames(data) #assign them as column names of the dataframe. This could be used to 
  
  for (trial in trials){
    #read the roi boundary
    roi <- get_shape(paste0(trial,"__",cycle,"__roi"),shpFolder)
    for(date in dates){
      for(cam in data[date,trial]){
        if (cam != "-"){
          #construct the codename of the image
          name <- paste0(cam,date,trial)
          ##path of the standard Pix4D folder structure
          path <- file.path(wd,name,name,"4_index","reflectance", fsep = "\\")
          ##Use the working directory path if all the imagery bands were copied to 1 same location
          #path <- wd 
          print(sprintf("processing bands... %s\\%s",path,name))
          #stack the bands and save in the WD
          s <- stackSeq(name,path)
          #cut the excess outside the ROI boundary
          s_crop<-crop(s, extent(roi), snap="out") #require(raster)
          outFile <- file.path(wd,paste0(name,"rfl.tif"), fsep = .Platform$file.sep)
          print(paste("will write this to disk: ",outFile))
          writeRaster(s_crop, file=outFile, datatype='FLT4S',format="GTiff",overwrite=FALSE)
        }  
      } 
    }
  }
})
