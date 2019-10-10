####
# it is used to stack in one file the individual bands from the sequoia ( for COMPASS)
# Select only the 4 band to stack !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT
## Depends on functions_ImgProcessing.R

#0. First step : load packages
#install.packages(c("rgdal","raster"))
#require(raster)
#require(rgdal) #it is called in the functions file

################### Functions
source(file.path("C:","Dropbox","Software","Scripts","r","functions_ImgProcessing.R", fsep = .Platform$file.sep))

############### Script
tryCatch({
  #Call function with the images as parameters
  print ("################# Inicio de script ##################")
  args <- commandArgs(TRUE)
  #See the inputs
  ## read the args and call the function in pairs
  nargs <- length(args)
  message("# of bands to process: ",nargs)
  ## Get folder from the first file
  path<-dirname(normalizePath(args[1]))
  #print(path)
  #Img basename without extention
  name <- basename(args[1])
  ext <- ".tif"
  name<-gsub(ext, "", name)
  ##Base image name of all the bands (separate by the "_" and get the first element) ej Imagename: "basename_transparent_reflectance_green.tif"
  name <- unlist(strsplit(name,"_"))[1]
  ## STACK BANDS OF SEQUAOIA:
  s <- stackSeq(name,path,ext)
  #Save
  outFile <- file.path(path,paste0(name,"rfl.tif"), fsep = .Platform$file.sep)
  print(paste("will write this to disk: ",outFile))
  writeRaster(s, file=outFile, datatype='FLT4S',format="GTiff",overwrite=FALSE)
  print("Success in round!")

})
  