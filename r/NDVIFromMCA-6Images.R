#Script to calculate the NDVI from a folder of MCA-6 images BSQ format
#Files should be named as follows:
#  [camera(1 char)]yymmdd[AOI(3 char)][imageProcessingStage(3 char)].bsq
#Example: m151216jfxgeo.bsq
# The required input is: the working directory
#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(raster)
require(rgdal)
#NDVI function on a 6 band multispectral image
f_NDVI <- function(r,n) {
  (n-r)/(n+r)
}

#Function multibandStack (folder, nband_red, nband_nir)
nDVIFromMCA6 <- function(wd,red_band=2,nir_band=6) 
{
  tryCatch({
    setwd(wd)
    #Make a list of all files in the wd
    im <- list.files(wd, full.names=TRUE)
    #Select the *geo.bsq files
    im.bsq <- im[grep("geo.bsq$", im)]
    #generate NDVI of all rasters
    for (img in im.bsq) {
      img="C:/vuelos/temp/ad_nut_MCA/m151216jfxgeo.bsq" #Fixed testing
      r_red=raster(img, band=red_band)
      r_nir=raster(img, band=nir_band)
      NDVI <- f_NDVI(r_red,r_nir)
      #plot(NDVI) plot if we want to see it
      #Save the NDVI replacing the suffix of the images
      writeRaster(NDVI, file=gsub("geo.bsq$", "nvi.tif$", img),datatype='FLT4S', format="GTiff",overwrite=FALSE)
    }
  })
  
}

#Working directory
wd = "C:/vuelos/temp/ad_nut_MCA"
#Call NDV maker
n = nDVIFromMCA6(wd,2,6)
print ("Finished generating the NDVI for all the images")
