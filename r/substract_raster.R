require(rgdal)
require(raster)


###################### DEFINED FUNCTIONS (no need to edit)
#Function to substract the baseline to the DSM
rest <-function(r1,base){(r1-base)}

#Function to select the apropriate roi for the trial
# Read the feature class
get_roi <- function(trial_roi) {readOGR(dsn=fgdb,layer=trial_roi)}


######################## DEFINE VARIABLES (Enter your variables)
## WD
setwd("C:/Dropbox/Lectura y cursos/R/Cimmyt_Spatial Analysis in R/")

#Feature geodatabase to get ROI
fgdb = "C:\\Dropbox\\data\\AE\\physio\\ae_fisio.gdb"

imgLocation = "C:\\AE\\"
out_raster = "C:\\Dropbox\\data\\AE\\physio\\ae_fisio.gdb"

######################## Execute the thing
rasterBase <- raster("Data/Modis2008-2012/MYD13Q1.MRTWEB.A2012361.005.250m_16_days_NDVI.tif")
raster1 <- raster("Data/Modis2008-2012/MYD13Q1.MRTWEB.A2012265.005.250m_16_days_NDVI.tif")
#Select one file interactively
#raster <-raster(choose.files(default = getwd(), caption = "Select XX files",
#                             multi = FALSE, filter = Filters <- matrix(c("TIF", ".tif"),
#                                                                       1, 2, byrow = TRUE), index = 1))


#plot (raster1)

roi <- get_roi("hap__ae__bry")
#plot (roi)

##Crop raster
#r_crop<-crop(raster, extent(roi), snap="out")

#Substract rasters
height <- rest(raster1, rasterBase)
#plot(height)

##Save ROI to shp
#writeOGR(roi, "C:\\Dropbox\\data\\AE\\physio\\shp\\hap__ae__bry.shp", layer="hap__ae__bry.shp", driver="ESRI Shapefile")

##Name for resulting raster
out_raster <- "outputR"

#save raster
writeRaster(height, file= paste(imgLocation,out_raster,sep=""),datatype='FLT4S',format="GTiff",overwrite=FALSE)


#TESTS---------------------------------------------------------
dsm <- raster("G:/AE/161026/r161026fis/r161026hap/3_dsm_ortho/1_dsm/r161026hap_dsm.tif")
r_crop<-crop(dsm, extent(roi), snap="out")
plot(r_crop)
