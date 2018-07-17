#Script to separate the Multispectra bands from the iMapQ processing result that stacks them in 2 rasters of 3 bands.
#Names should be like:
# TTC[name]-0.tif
# TTC[name]-1.tif
# e.g. TTC07016-1.tif
# The required input is: the working directory
#The output is written in the same folder

#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(raster)
require(rgdal)
library(stringr)

########### Functions ##########################
#Function multibandUnStack
multibandUnStack <- function(img3Band) 
{
  tryCatch({
    ##img3Band <- "TTC07016-0.tif" ## %%%% ! HARDCODED TO TEST
    
    #Truncate string to Get base name of frame
    basename <- substr(toString(img3Band), 1, 8)
    #Truncate string to Get if the sufix of the filename is 0 or 1
    sx <- substr(toString(img3Band), 10, 10)
    # If it is 0 we will name the bands 1, 2, 3 otherwise 4, 5, 6
    # So fix will be used to use the index to asign the correct bandnumber
    fix <- if(sx==0) 0 else 3
    #separate Input file into 3 separate rasters
    for (i in 1:3){
      b <- raster(img3Band, band=i)
      rSave(b, paste(basename,"-b",i+fix,sep = ""))
    }

    ##plot(b1) #see image just to test

  })
}

#function to plot save image to disk
rSave <- function(img, name) 
{
  tryCatch({
    #Write the tif to disk
    writeRaster(img, file=paste(name,".tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
  })
}

########### START ##########################
#Working directory
wd="G:\\AE\\170531\\m\\rfl"
setwd(wd)
## Sets the pattern of name files to be processed (-0.tif and -1.tif) and process each one
imgFilesList <-list.files(wd, pattern="-{1}0*1*.tif$")
for (i in seq_along(imgFilesList)){
  print(paste("Image:",i,"of",toString(length(imgFilesList)),":",imgFilesList[i]))
  multibandUnStack(imgFilesList[i]) 
}

#Notify that it finished
print(paste("Finished merging",toString(length(imgFilesList)),"images"))