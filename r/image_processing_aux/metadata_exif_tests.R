##Load package to read EXIF
require(exiftoolr)
require(grDevices)
library(ggplot2)  # gramar graphics
##Al ejecutar por primera vez la extensión  necesitas correr el comando de instalarla... <<<< NOTA
#install_exiftool()

## Set Working directory
setwd(choose.dir()) #interactive selection of Wording directory
#setwd ("E:\\AG\\190207\\e\\0001SET\\002") hardcoded selection of the working directory
## Read the tiff files that en with _1, just to get one band as example
files <- list.files(pattern = "*_4.tif",recursive = TRUE) #you can use the recursive = TRUE parameter if you want to read the subdirectories
##Read metadata of those images and save as Dataframe
## This seems to be working properly
meta <- exif_read(files)

##Plot map of the images location
plot(meta$GPSLongitude,meta$GPSLatitude)
## plot values of irradiance
plot(meta$Irradiance)
##plot irradiance vs...
plot(meta$IrradianceYaw,meta$Irradiance)
plot(meta$IrradianceRoll,meta$Irradiance)
plot(meta$IrradiancePitch,meta$Irradiance) #no parece contribuir mucho

##Plot the map with the irradiance as gradient symbology  + yaw as point size
ggplot(data = meta, 
       mapping = aes(x = GPSLongitude, y = GPSLatitude)) + 
  geom_point(mapping = aes(size = as.numeric(IrradianceYaw), colour = as.numeric(Irradiance)))+
  scale_color_gradient(low="orange", high="yellow")

##Plot the map with the irradiance as gradient symbology
ggplot(data = meta, 
       mapping = aes(x = GPSLongitude, y = GPSLatitude)) + 
  geom_point(mapping = aes(size = 15,colour = as.numeric(Irradiance)))+
  scale_color_gradient(low="orange", high="yellow")
##Plot the map with the irradiance as gradient symbology + Roll as point size
ggplot(data = meta, 
       mapping = aes(x = GPSLongitude, y = GPSLatitude)) + 
  geom_point(mapping = aes(size = as.numeric(IrradianceRoll), colour = as.numeric(Irradiance)))+
  scale_color_gradient(low="orange", high="yellow")

##Plot the map with the irradiance as gradient symbology + Pitch as point size
ggplot(data = meta, 
       mapping = aes(x = GPSLongitude, y = GPSLatitude)) + 
  geom_point(mapping = aes(size = as.numeric(IrradiancePitch), colour = as.numeric(Irradiance)))+
  scale_color_gradient(low="orange", high="yellow")

##Plot  irradiance vs Yaw vs Roll
ggplot(data = meta, 
       mapping = aes(y = as.numeric(IrradianceYaw), x = as.numeric(IrradianceRoll))) + 
  geom_point(mapping = aes( colour = as.numeric(Irradiance)))

##Write data
## Need to unlist "meta" to be able to do it... TODO
#write.csv(meta,"metadata.csv")

