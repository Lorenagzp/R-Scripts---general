## To show the histogram of selected plots in shapefile
## ONGOING WORK!!!!

require(raster)
require(rgdal)

###################### DEFINED FUNCTIONS (no need to edit)
# Read the feature class
get_roi <- function(trial_roi) {readOGR(dsn=fgdb,layer=trial_roi)}


######################## DEFINE VARIABLES (Enter your variables)
# #Working directory
wd="G:\\AD15_16\\"
setwd(wd)
ext<-".tif"
shp_name<- "__ad__buf"
sx<-"cel" #input sufix
fgdb = "C:\\Dropbox\\data\\AD\\ad_sam\\shp\\adsam.gdb"

#Select individual image instead of loop all
  cam<-"t"
  d<-"160804"
  t<-"sam"

######################### STARTs SCRIPT
tryCatch({
  


  imgLocation =  paste(wd,d,"\\",cam,"\\",sx,"\\",sep="") #Look into cel folder
  name = paste(cam,d,t,sx,ext,sep="")
  rasterName= paste(imgLocation,name,sep="")
  r<-raster(rasterName)
  plt <- get_roi(paste(t,shp_name,sep=""))
  ids <- data.frame(plt$id)
  
  ##Graphics to save to PDF
  pdf(file=paste(name," plots.pdf", sep=""))
  par(mar = rep(2, 4),mfrow=c(4,4))
  
  #Iterate the plots
  for(i in 1:3){ ###length(ids[,1]) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ##Select every plot polygon
    roi <- plt[plt@data["id"]==ids[i,1]] #%%%%%%%%%%%%%%%%%% WTFFF   %%%%%%%%%%%%%%%%
    print(ids[i,1])
    ##roi <- plt[plt$id=="thanda 264 rows  /131",]
    ##Crop the image to get what is inside the plot
    r_selected <-crop(r, extent(roi), snap="out")
    plot(r_selected,col=heat.colors(8,0.8)) # Plot the image cropped
    #Get histogram of that piece of image
    hist(r_selected,main=paste(t,cam,d,"plot= [",ids[i,1],"]"),breaks=20)
    
    # KMEANS
    #assume bimodal distribution in clipped raster
    #Use K means to filter Soil (hotter pixels)
    #The group 1 is the cooler (vegetation?) and the 2 is the hotter (Soil?)
    v<-data.frame(getValues(r_selected))
    km <- kmeans(v,centers=2)
    v$clust <- as.factor(km$cluster)
    hist(v[v$clust==1,1])
    #Store mean plot value in table
    ids$d[i] <- mean(v[v$clust==1,1])
    
    #NIBLACK????
    #Filter soil with this filter
    #pixel = ( pixel >  mean + k * standard_deviation - c) ? object : background
#     sd(r_selected)
#     r_mean <- focal(r_selected, w=matrix(1/9,nrow=5,ncol=5))
     ##How to calculate focal std ?
#     sd(x, na.rm = FALSE)
#     zonal(x, z, stat='mean', digits=0, na.rm=TRUE, ...) 
#     focal(r_selected, w=3, fun=, na.rm=TRUE) 
#     sd2 <- sqrt(sum((x - mean(x))^2) / (n - 1))
#     
#     #r_sd <- cellStats(r_selected,'sd') # Returns a value, not raster
#     add=TRUE
#     plot(r_mean)
#     plot(r_sd)
  }
  
  dev.off()
  ##Finish saving to PDF

})

