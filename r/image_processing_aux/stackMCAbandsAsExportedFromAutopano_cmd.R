#Script to stack the Multispectra bands from the Autopano mosaic
#Selecting them in the windows explorer and executing this file
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
multibandStack <- function(img_0,img_1) 
{
  tryCatch({
    print(paste("primeras 3 bandas",img_0))
    print(paste("últimas 3 bandas",img_1))
    wd<-dirname(normalizePath(img_0))
    #print(wd)
    setwd(wd)
    #Img basename
    imgBasename<-gsub("-0.tif", "", img_0)
    #print(imgBasename)
    #stack 6 bands in one pile
    img=stack(list(img_0=img_0,img_1=img_1)) 
    #Write the tif to disk
    writeRaster(img, file=paste(imgBasename,".tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    print(paste("Imagen escrita: ",imgBasename,".tif",sep = ""))
  })
}

#Call function with the images as parameters
print ("################# Inicio de script ##################")
args <- commandArgs(TRUE)
args<- sort(args)
#See the inputs
## Loop the args and call the function in pairs
nargs <- length(args)/2
print (paste("# of images to create:",nargs))
for (i in 1:nargs){
  #print(args[2*i-1])
  #print(args[2*i])
  multibandStack(args[2*i-1],args[i*2])
  print("Success in round!")
}

