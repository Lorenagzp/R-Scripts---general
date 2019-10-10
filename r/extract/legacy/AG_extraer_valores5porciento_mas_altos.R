
################### Functions
source(file.path("C:","Dropbox","Software","Scripts","r","functions_ImgProcessing.R", fsep = .Platform$file.sep))

################### Script

### set Working directory ###
Folder = file.path("C:","Dropbox", "data","AG","FR","pruebas 5 porciento", fsep = .Platform$file.sep)
setwd(Folder)
#setwd(choose.dir()) # OR interactive selection of Wording directory

### Get data ###
#Get roi to mask crop polygon
# the roi is the polygon we use as areas to extract the ndvi values the codename "GSA" = greenseeker areas, includes PA = area productor, FR= franja rica... 
#Feature geodatabase to get ROIS
fgdb = file.path("C:","Dropbox", "data","AG","FR","AF_FR.gdb", fsep = .Platform$file.sep)
roi_name= "rey190118gsa_1"                                     ########### This is where you select the ROI of the areas of interest ######### %$"#
crop_roi <- readOGR(dsn = fgdb, layer = roi_name)
#choose image file                                            ########### This is where you select the image ######### %$"#
i <- chooseTif()

### Call function ###
#Get the mean value of the 5% higher pixels. Saves PDF with plots on default working directory
mean5percTop<- getTop5percInsideROIandRemoveFR(i,crop_roi)

### Write to file the log ###
log = data.frame(
  imgName = i,
  feature = roi_name,
  mean5perc = mean5percTop)
write.table(log, file = "mean of top5percent log.csv",row.names=FALSE, append = TRUE,sep = ",",col.names = FALSE)