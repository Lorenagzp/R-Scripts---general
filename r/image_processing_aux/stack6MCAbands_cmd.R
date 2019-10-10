#Script to stack the Multispectra bands from MCA camera
#Selecting them in the windows explorer and executing this file
#Names should be like:
# m[date][trial]-0_1.tif
# m[date][trial]-0_2.tif
# m[date][trial]-0_3.tif
# m[date][trial]-1_1.tif
# e.g. m160204bw8pno-1.tif
#This is assuming the name formatting of the greenplane


#TODO:
#################################################Hardcoded the ROI shapefile, make interactive selsction !!!!


#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(rgdal)
require(raster)
source((file.path("F:","Dropbox","Software","Scripts","r","functions_ImgProcessing.R", fsep = .Platform$file.sep)))

#Call function with the images as parameters
print ("################# Inicio de script ##################")
args <- commandArgs(TRUE)
args<- sort(args) #this sorts the input

wd<-dirname(normalizePath(args[1]))
#print(wd)
setwd(wd)

#Choose the roi
#roi_location <-   choose.files(default = "", caption = "Selecciona el archivo shapefile con el ROI para cortar las bandas",
#                            multi = FALSE, filters = matrix(c("shp", "*.shp")),
#                            index = nrow(Filters))
#roi_path <-dirname(normalizePath(roi_location))
#roi <-get_shape("LTP1_2_E","G:\\temp\\shp") #################################################Hardcoded

#call the stack

print("Images to stack (in this order)")
for (arg in args) {
  print(arg)
}
## Use the next to stack if they are separated the 6 bands
multibandStack6(args[1],args[2],args[3],args[4],args[5],args[6],roi=roi)
print("Success in round!")


