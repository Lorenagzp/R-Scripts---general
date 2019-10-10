#Script to unstack the Multispectra bands from the MCA 3-band-pack
#Selecting them in the windows explorer and executing this file (from the send to right-click menu)
#Names should be like:
# m[date][trial]pno-0.tif
# m[date][trial]pno-1.tif
# e.g. m160204bw8pno-1.tif
#This is assuming the name formatting of the greenplane
#TODO:
######filter to accept the input files in any order
#######(so far cant stack if the files are not ordered by name)


#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(rgdal)

require(raster)

#Function multibandStack
multibandStack <- function(img_3) 
{
  tryCatch({
    print(paste("Dividir primeras 3 bandas",img_3))
    wd<-dirname(normalizePath(img_3))
    #print(wd)
    setwd(wd)
    #Img basename without extention
    imgBasename<-gsub(".tif", "", img_3)
    #print(imgBasename)
    #separate the bands
    img1=raster(img_3, band = 1)
    img2=raster(img_3, band = 2) 
    img3=raster(img_3, band = 3) 
    #Write the 3 tif to disk
    writeRaster(img1, file=paste(imgBasename,"_1.tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    writeRaster(img2, file=paste(imgBasename,"_2.tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    writeRaster(img3, file=paste(imgBasename,"_3.tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    print(paste("Imagen escrita: ",imgBasename,".tif",sep = ""))
  })
}

#Call function with the images as parameters
print ("################# Inicio de script ##################")
args <- commandArgs(TRUE)
args<- sort(args)
#See the inputs
## Loop the args and call the function
nargs <- length(args)
print (paste("# of images to create:",nargs))
for (i in 1:nargs){
  #print(args[2*i-1])
  #print(args[2*i])
  multibandStack(args[i])
  print("Success in round!")
}

