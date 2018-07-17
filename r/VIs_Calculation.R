#####################################################################
# Title: ENVI_Indices
# Name: Francisco Manuel Rodriguez Huerta
# Date: 9 Abril 2014
# Description: Compute Indices
#####################################################################

#Load required libraries
require(raster)
require(rgdal)

### nos posicionamos en el directorio de trabajo ###
rm(list = ls()) 

work.dir <- "I:\\CIMMYT\\YQ_Variability\\Data\\Images_PAexp\\1200m\\Resampled"  ### Change the input directory

setwd(work.dir)
getwd()

#set filename
filename<-"H140507_PA_1m_62bands.dat"   ### check file name


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

R <- getValuesBlock(rs, row=1, nrows=nr, col=1, ncols=nc)/10000
dim(R)

#read identifier of bands and wavelengths

#setwd("H:\\CIMMYT\\YQ_Variability\\Data\\Images_PAexp\\")
#getwd()


bands <- read.table("bands62.csv",sep=",",header=TRUE)

setwd("I:\\CIMMYT\\YQ_Variability\\Data\\Images_PAexp\\1200m\\VIs\\140507")  ### Output folder to VI maps
getwd()


#Important bands
R400 <- R[,bands[which.min(abs(bands[,2]-400)),1]]
R445 <- R[,bands[which.min(abs(bands[,2]-445)),1]]
R450 <- R[,bands[which.min(abs(bands[,2]-450)),1]]
R470 <- R[,bands[which.min(abs(bands[,2]-470)),1]]
R500 <- R[,bands[which.min(abs(bands[,2]-500)),1]]
R510 <- R[,bands[which.min(abs(bands[,2]-510)),1]]
R513 <- R[,bands[which.min(abs(bands[,2]-513)),1]]
R515 <- R[,bands[which.min(abs(bands[,2]-515)),1]]
R530 <- R[,bands[which.min(abs(bands[,2]-530)),1]]
R550 <- R[,bands[which.min(abs(bands[,2]-550)),1]]
R570 <- R[,bands[which.min(abs(bands[,2]-570)),1]]
R635 <- R[,bands[which.min(abs(bands[,2]-635)),1]]
R670 <- R[,bands[which.min(abs(bands[,2]-670)),1]]
R675 <- R[,bands[which.min(abs(bands[,2]-675)),1]]
R680 <- R[,bands[which.min(abs(bands[,2]-680)),1]]
R700 <- R[,bands[which.min(abs(bands[,2]-700)),1]]
R710 <- R[,bands[which.min(abs(bands[,2]-710)),1]]
R720 <- R[,bands[which.min(abs(bands[,2]-720)),1]]
R740 <- R[,bands[which.min(abs(bands[,2]-740)),1]]
R746 <- R[,bands[which.min(abs(bands[,2]-746)),1]]
R750 <- R[,bands[which.min(abs(bands[,2]-750)),1]]
R760 <- R[,bands[which.min(abs(bands[,2]-760)),1]]
R770 <- R[,bands[which.min(abs(bands[,2]-770)),1]]
R800 <- R[,bands[which.min(abs(bands[,2]-800)),1]]

hist(R500)
hist(R800)
###################
### Get indices ###
###################
date <- strsplit(filename,split="_")[[1]][1]

#Structural Indices
NDVI <- (R800-R670)/(R800+R670)
Rastout <- raster(ncol=nc,nr=nr)
Rastout[] <- NDVI
Rastout@extent <- rs@extent
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout, filename=paste(date,"NDVI.tif",sep="_"), format="GTiff")
hist(NDVI)


RDVI <- (R800-R670)/sqrt(R800+R670)
Rastout[] <- RDVI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"RDVI.tif",sep="_"),format="GTiff")

OSAVI <- (1+0.16)*(R800-R670)/(R800+R670+0.16)
Rastout[] <- OSAVI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"OSAVI.tif",sep="_"),format="GTiff")

SR <- R800/R670
Rastout[] <- SR
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"SR.tif",sep="_"),format="GTiff")

MSR <- (SR-1)/sqrt(SR)+1
Rastout[] <- MSR
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"MSR.tif",sep="_"),format="GTiff")

MTVI1 <- 1.2*(1.2*(R800-R550)-2.5*(R670-R550))
Rastout[] <- MTVI1
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"MTVI1.tif",sep="_"),format="GTiff")

MCARI1 <- 1.2*(2.5*(R800-R670)-1.3*(R800-R550))
Rastout[] <- MCARI1
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"MCARI1.tif",sep="_"),format="GTiff")

deno <- sqrt((2*R800+1)^2-(6*R800-5*sqrt(R670))-0.5)
MCARI2 <- (1.5/1.2)*MCARI1/deno
Rastout[] <- MCARI2
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"MCARI2.tif",sep="_"),format="GTiff")

MTVI2 <- (1.5/1.2)*MTVI1/deno
Rastout[] <- MTVI2
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"MTVI2.tif",sep="_"),format="GTiff")

#Chlorophyll indices
TVI <- 0.5*(120*(R750-R550)-200*(R670-R550))
Rastout[] <- TVI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"TVI.tif",sep="_"),format="GTiff")

MCARI <- ((R700-R670)-0.2*(R700-R550))*(R700/R670)
Rastout[] <- MCARI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"MCARI.tif",sep="_"),format="GTiff")

TCARI <- 3*MCARI
Rastout[] <- TCARI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"TCARI.tif",sep="_"),format="GTiff")

TCARI_OSAVI <- TCARI/OSAVI
Rastout[] <- TCARI_OSAVI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"TCARI_OSAVI.tif",sep="_"),format="GTiff")

MCARI_OSAVI <- MCARI/OSAVI
Rastout[] <- MCARI_OSAVI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"MCARI_OSAVI.tif",sep="_"),format="GTiff")

GM1 <- R750/R550
Rastout[] <- GM1
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"GM1.tif",sep="_"),format="GTiff")

GM2 <- R750/R700
Rastout[] <- GM2
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"GM2.tif",sep="_"),format="GTiff")


#Red edge ratios
#ZM
CI <- R750/R710
Rastout[] <- CI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"CI.tif",sep="_"),format="GTiff")

R750_R700 <- R750/R700
Rastout[] <- R750_R700
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"R750_R700.tif",sep="_"),format="GTiff")

R750_R670 <- R750/R670
Rastout[] <- R750_R670
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"R750_R670.tif",sep="_"),format="GTiff")

R710_R700 <- R710/R700
Rastout[] <- R710_R700
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"R710_R700.tif",sep="_"),format="GTiff")

R710_R670 <- R710/R670
Rastout[] <- R710_R670
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"R710_R670.tif",sep="_"),format="GTiff")

#RGB Indices
R700_R670 <- R700/R670
Rastout[] <- R700_R670
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"R700_R670.tif",sep="_"),format="GTiff")

G <- R550/R670
Rastout[] <- G
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"G.tif",sep="_"),format="GTiff")

#Indices PDF
CAR <- R515/R570
Rastout[] <- CAR
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"CAR.tif",sep="_"),format="GTiff")

PRI <- (R570-R530)/(R570+R530)
Rastout[] <- PRI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PRI.tif",sep="_"),format="GTiff")

PRIn <- PRI*R670/(RDVI*R700)
Rastout[] <- PRIn
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PRIn.tif",sep="_"),format="GTiff")

SIPI <- (R800-R445)/(R800+R680)
Rastout[] <- SIPI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"SIPI.tif",sep="_"),format="GTiff")

RARS <- R746/R513
Rastout[] <- RARS
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"RARS.tif",sep="_"),format="GTiff")

PSSRa <- R800/R680
Rastout[] <- PSSRa
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PSSRa.tif",sep="_"),format="GTiff")

PSSRb <- R800/R635
Rastout[] <- PSSRb
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PSSRb.tif",sep="_"),format="GTiff")

PSSRc <- R800/R470
Rastout[] <- PSSRc
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PSSRc.tif",sep="_"),format="GTiff")

PSNDc <- (R800-R470)/(R800+R470)
Rastout[] <- PSNDc
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PSNDc.tif",sep="_"),format="GTiff")

RNIRxCRI550 <- (1/R510)-(1/R550)*R770
Rastout[] <- RNIRxCRI550
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"RNIRxCRI550.tif",sep="_"),format="GTiff")

RNIRxCRI700 <- (1/R510)-(1/R700)*R770
Rastout[] <- RNIRxCRI700
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"RNIRxCRI700.tif",sep="_"),format="GTiff")

PRI515 <- (R515-R530)/(R515+R530)
Rastout[] <- PRI515
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PRI515.tif",sep="_"),format="GTiff")

PRIxCI <- PRI*((R760/R700)-1)
Rastout[] <- PRIxCI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PRIxCI.tif",sep="_"),format="GTiff")

PSRI <- (R680-R500)/R750
Rastout[] <- PSRI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"PSRI.tif",sep="_"),format="GTiff")

VOG <- R740/R720
Rastout[] <- PSRI
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"VOG.tif",sep="_"),format="GTiff")

BGI1 <- R400/R550
Rastout[] <- BGI1
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"BGI1.tif",sep="_"),format="GTiff")

BGI2 <- R450/R550
Rastout[] <- BGI2
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"BGI2.tif",sep="_"),format="GTiff")

EVI <- 2.5*(R800-R670)/(R800+6*R670-7.5*R400+1)
Rastout[] <- EVI 
proj4string(Rastout) <- CRS("+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
writeRaster(Rastout,filename=paste(date,"EVI.tif",sep="_"),format="GTiff")







