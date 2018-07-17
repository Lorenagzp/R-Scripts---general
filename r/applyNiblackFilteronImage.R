#Apply the niblack filter on an image
# february 2018
# !!!!!!!!!!!!!!! !# ongoing work

library (raster)

getTop5percInsideROIandRemoveFR <- function (i,fgdb,roi_name){
  
  meanImg <- cellStats(img95, stat='mean', na.rm=TRUE)
  
  focal(x, w, fun, filename='', na.rm=FALSE, pad=FALSE, padValue=NA, NAonly=FALSE, ...)
