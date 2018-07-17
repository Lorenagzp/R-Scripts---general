#####################################################################
# Title: ENVI_Indices for Multispec 4C images
# Name: Francisco Manuel Rodriguez Huerta, edited by Lorena GP
# Date: 9 Abril 2014. Sep 13 2016
# Description: Compute Indices
#####################################################################

#Load required libraries
require(raster)
require(rgdal)

### nos posicionamos en el directorio de trabajo ###
rm(list = ls()) 
work.dir <- "G:\\AD15_16\\AF\\Processed\\CompB_geo\\"  ### Change the input directory
setwd(work.dir)
getwd()

#set filename
filename<-"c160407_afgeo.bsq"   ### check file name

#create rasterstack object
r1 <- raster(filename, band=1)
rs <- stack(r1)
index <- r1@file@nbands
rm(r1)
for (i in 2:index){
	r1 <- raster(filename, band=i)
	rs <- stack(rs,r1)
	rm(r1)
}
show(rs)

#numbers of rows and columns
nr <- nrow(rs)
nc <- ncol(rs)
nlayers(rs)

#get values
R <- getValuesBlock(rs, row=1, nrows=nr, col=1, ncols=nc)
dim(R)

#read identifier of bands and wavelengths
bands <- read.table("bands_multispec4c.csv",sep=",",header=TRUE) #### Bands

setwd("C:\\Dropbox\\data\\AD\\AD-AF\\img\\vi")  ### Output folder to VI maps
getwd()

#Important bands
R550 <- R[,1]
R670 <- R[,2]
R680 <- R[,2]
R750 <- R[,3]
R800 <- R[,4]

###################
### Calculate indices ###
###################
date <- strsplit(filename,split="_")[[1]][1]
#Define coordinate system to be applied
coord_sys = CRS("+proj=utm +zone=14 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

#Structural Indices
NDVI <- (R800-R670)/(R800+R670)
Rastout <- raster(ncol=nc,nr=nr)
Rastout[] <- NDVI
Rastout@extent <- rs@extent
proj4string(Rastout) <- coord_sys
writeRaster(Rastout, filename=paste(date,"NDVI.tif",sep="_"), format="GTiff")
#hist(NDVI)

RDVI <- (R800-R670)/sqrt(R800+R670)
Rastout[] <- RDVI
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"RDVI.tif",sep="_"),format="GTiff")

OSAVI <- (1+0.16)*(R800-R670)/(R800+R670+0.16)
Rastout[] <- OSAVI
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"OSAVI.tif",sep="_"),format="GTiff")

 SR <- R800/R670
# Rastout[] <- SR
# proj4string(Rastout) <- coord_sys
# writeRaster(Rastout,filename=paste(date,"SR.tif",sep="_"),format="GTiff")

MSR <- (SR-1)/sqrt(SR)+1
Rastout[] <- MSR
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"MSR.tif",sep="_"),format="GTiff")

MTVI1 <- 1.2*(1.2*(R800-R550)-2.5*(R670-R550))
Rastout[] <- MTVI1
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"MTVI1.tif",sep="_"),format="GTiff")

MCARI1 <- 1.2*(2.5*(R800-R670)-1.3*(R800-R550))
Rastout[] <- MCARI1
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"MCARI1.tif",sep="_"),format="GTiff")

deno <- sqrt((2*R800+1)^2-(6*R800-5*sqrt(R670))-0.5)
MCARI2 <- (1.5/1.2)*MCARI1/deno
Rastout[] <- MCARI2
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"MCARI2.tif",sep="_"),format="GTiff")

MTVI2 <- (1.5/1.2)*MTVI1/deno
Rastout[] <- MTVI2
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"MTVI2.tif",sep="_"),format="GTiff")

#Chlorophyll indices
TVI <- 0.5*(120*(R750-R550)-200*(R670-R550))
Rastout[] <- TVI
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"TVI.tif",sep="_"),format="GTiff")

GM1 <- R750/R550
Rastout[] <- GM1
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"GM1.tif",sep="_"),format="GTiff")


G <- R550/R670
Rastout[] <- G
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"G.tif",sep="_"),format="GTiff")

#Indices PDF

PSSRa <- R800/R680
Rastout[] <- PSSRa
proj4string(Rastout) <- coord_sys
writeRaster(Rastout,filename=paste(date,"PSSRa.tif",sep="_"),format="GTiff")