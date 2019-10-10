#functions for image processinh

require(raster)
#Para agarrar las 4 bandas de reflectancia de la sequoia y unirlas en un archivo
#Utiliza el nombre base para cargar las bandas con su nombre
stackSeq <- function(name,path,ext){
  r_green <- file.path(path,paste0(name,"_transparent_reflectance_","green",ext), fsep = .Platform$file.sep)
  r_red   <- file.path(path,paste0(name,"_transparent_reflectance_","red",ext), fsep = .Platform$file.sep)
  r_rededge <- file.path(path,paste0(name,"_transparent_reflectance_","red edge",ext), fsep = .Platform$file.sep)
  r_nir <- file.path(path,paste0(name,"_transparent_reflectance_","nir",ext), fsep = .Platform$file.sep)
  #print(r_nir)
  s <- stack(r_green,
             r_red,
             r_rededge,
             r_nir)
 return(s)
}


##Para agarrar las 5 bandas de reflectancia de la c?mara RedEdge y unirlas en un archivo
##Utiliza el nombre base para cargar las bandas con su nombre
stackRedge <- function(name,path,ext){
  r_blue <- file.path(path,paste0(name,"_transparent_reflectance_","blue",ext), fsep = .Platform$file.sep)
  r_green <- file.path(path,paste0(name,"_transparent_reflectance_","green",ext), fsep = .Platform$file.sep)
  r_red   <- file.path(path,paste0(name,"_transparent_reflectance_","red",ext), fsep = .Platform$file.sep)
  r_rededge <- file.path(path,paste0(name,"_transparent_reflectance_","red edge",ext), fsep = .Platform$file.sep)
  r_nir <- file.path(path,paste0(name,"_transparent_reflectance_","nir",ext), fsep = .Platform$file.sep)
  #print(r_nir)
  s <- stack(r_blue,
             r_green,
             r_red,
             r_rededge,
             r_nir)
  return(s)
}


require(rgdal)
##### Creo que los de leer shp no est?n funcionando
# Read the feature class
get_feature <- function(feature,database) {readOGR(dsn=database,layer=feature)}
# Read a shapefile
get_shape <- function(shape,path){readOGR(dsn = path, layer = shape)}


#Function multibandStack to join the 6 bands of the MCA, cropping first
multibandStack6 <- function(b1,b2,b3,b4,b5,b6,roi) 
{
  tryCatch({
    #Img basename
    imgBasename<-gsub("-B1.tif", "", b1)
    #print(imgBasename)
    #Open the rasters frtom their name
    b1 <- raster(b1)
    b2 <- raster(b2)
    b3 <- raster(b3)
    b4 <- raster(b4)
    b5 <- raster(b5)
    b6 <- raster(b6)
    #Crop rasters with ROI, 
    #do we need this?
    #b1<-crop(raster(b1), extent(roi), snap="in")
    #b2<-crop(raster(b2), extent(roi), snap="in")
    #b3<-crop(raster(b3), extent(roi), snap="in")
    #b4<-crop(raster(b4), extent(roi), snap="in")
    #b5<-crop(raster(b5), extent(roi), snap="in")
    #b6<-crop(raster(b6), extent(roi), snap="in")
    #Resample to make it align
    print("Images will be resampled and aligned to the first band")
    b2 <-resample(b2, b1, method="ngb")
    b3 <-resample(b3, b1, method="ngb")
    b4 <-resample(b4, b1, method="ngb")
    b5 <-resample(b5, b1, method="ngb")
    b6 <-resample(b6, b1, method="ngb")
    #stack 6 bands in one pile
    img=stack(list(b1=b1,b2=b2,b3=b3,b4=b4,b5=b5,b6=b6)) 
    #Write the tif to disk
    writeRaster(img, file=paste(imgBasename,".tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    print(paste("Imagen escrita: ",imgBasename,".tif",sep = ""))
  })
}

#require(rgdal)
#require(raster)
#Script to unstack the Multispectra bands from the MCA 3-band-pack
multibandUnStack <- function(img_3) 
{
  tryCatch({
    print(paste("Dividir primeras 3 bandas",img_3))
    wd<-dirname(normalizePath(img_3))
    #print(wd)
    setwd(wd)
    #Img basename without extention
    imgBasename<-gsub(".tif", "", img_3)
    #print(imgBasename)
    #separate the bands
    img1=raster(img_3, band = 1)
    img2=raster(img_3, band = 2) 
    img3=raster(img_3, band = 3) 
    #Write the 3 tif to disk
    writeRaster(img1, file=paste(imgBasename,"_1.tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    writeRaster(img2, file=paste(imgBasename,"_2.tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    writeRaster(img3, file=paste(imgBasename,"_3.tif",sep = ""),datatype='INT2U',format="GTiff",overwrite=FALSE)
    print(paste("Imagen escrita: ",imgBasename,".tif",sep = ""))
  })
}

#Function multibandStack
slantrange3bandStack <- function(imgBasename, wd) 
{
  tryCatch({
    setwd(wd)
    #Input file with bands 1 : 532 nm
    img_basename<-imgBasename
    img_1<-paste(img_basename,'.532nm.tif',sep = "")
    imported_raster_1=raster(img_1)
    
    #Input file with bands 3: 650 nm
    img_3<-paste(img_basename,'.650nm.tif',sep = "")
    imported_raster_3=raster(img_3)
    
    #Input file with bands 4: 850 nm
    img_4<-paste(img_basename,'.850nm.tif',sep = "")
    imported_raster_4=raster(img_4)
    
    
    #plot(imported_raster_0) #see image just to test
    #stack 6 bands in one pile
    img=stack(list(img_1,img_3,img_4)) 
    img[img==0] <- NA #Set 0 as no data
    
    #Write the tif to disk
    writeRaster(img, file=paste(imgBasename,"stack.tif",sep = ""),datatype='FLT4S',format="GTiff",overwrite=FALSE) 
  })
}

###########Function to execute the top 5% mean value. Saves PDF with plots on default working directory. For a roi with rich strip (FR) and AP, AS (Farmer and sensor area) 
## INPUTS
#NDVI_img: image full filename, including path
#roi:  (needs to contain a field "area" that identifies the area, and the ruch strip should have the "FR" value)
#       feature polygon to delimit the area of interest, the "GSA" polygons used to extract the values the image to compare to the GS.
getTop5percInsideROIandRemoveFR <- function (i,roi){
  #The next line is to save to PDF all the plots
  #Get image basename name without extention
  i_name <- basename(tools::file_path_sans_ext(i))
  pdf(file=paste("Plot_hist_",i_name,".pdf", sep=""))
  
  #raster
  img <- raster(i)
  print(c("Image used: ",i)) #Print status of image
  #plot(img)
  
  ##Get feature to clip, from the GDB
  roi <- roi[roi$area  != "FR"  ,] #Select only the features that dont correspond to the rich strip "FR" (i.e, the AP areas)
  #plot(roi)
  
  ##Mask image
  img_c <- crop(img, extent(roi))#First crop the area outside the bounding box
  print("Masking...")
  msk <- mask(img_c, roi) ##inverse=TRUE
  
  #Plot
  print("Values before the 5% top treshold")
  hist(msk)
  plot(msk)
  plot(roi,add=TRUE)
  
  q95 <- quantile(msk, c(.95))
  sprintf("Quantile 95perc: %.4f",q95) #Print quantile break
  
  #filter the 95%
  img95 <- msk
  img95[img95 < q95] <- NA
  #get the mean value from the filtered image
  print("Get mean value of top 5% pixels in the histogram...")
  meanImg <- cellStats(img95, stat='mean', na.rm=TRUE)
  plot(img95,main= sprintf("Quantile 95perc: %.4f",q95))
  hist(img95, main= sprintf("mean of 5perc. top NDVI values from the image %.4f",meanImg))
  
  print(paste("5% top NDVI values from the image",meanImg)) # 5% top NDVI values from the image
  
  #This stops the PDF capture
  dev.off()
  
  return(meanImg)
  
}


### function to separate the files from the thermal imagery that correspond to a specific area, based on the autopano mosaic file.
### The output folder is created based on the name of the autopano file, at the same level as the folder of the images
### LIBRARY
library(stringr)
separate_img_in_folder_from_pano_file <- function(pano_file_name){
  ### SCRIPT
  
  ##get the list of images that we want from the pano file
  pano_txt <- readLines(pano_file_name) #read text (it is an XML file)
  target_imgs <- str_extract(pano_txt, "filename=.*\\.tif") #Match anything that has a filename =          something    .tif
  target_imgs <- target_imgs[!is.na(target_imgs)] # remove what didnt match the pattern
  target_imgs <- sub("filename=\"","",target_imgs) # remove the "  filename="  " string. The " need to be escaped with the \ to be read as plain text
  
  ##move the selected images to the output folder
  #setup output folder
  output_folder <- tools::file_path_sans_ext(basename(pano_file_name))  # name of folder to move selected images
  full_output_folder <- file.path(dirname(dirname(target_imgs[1])),output_folder, fsep = .Platform$file.sep) #construct "output folder" in the location of the folder of the images
  message("images will be moved to: ", full_output_folder)
  dir.create(full_output_folder, showWarnings = FALSE)
  #move images
  total <- 0 #count them
  tryCatch(
    for (i in target_imgs) {
      #move if file exists
      if (file.exists(i)) {
        message("moving: ",i)
        file.copy(i, full_output_folder) #move. This also accepts itself a list tof files to move
        file.remove(i) #remove from original location if succesfully copied
        total <- total + 1
        
      } 
    }
    
  )
  message("moved a total of ", total, " images to: ", full_output_folder)
}

### function to separate the files from the slantrange 3band stacked imagery that correspond to a specific area, based on the autopano mosaic file.
### The output folder is created based on the name of the autopano file, at the same level as the folder of the images
### LIBRARY
library(stringr)
get_filenames_from_pano_file_slantrange3 <- function(pano_file_name){
  ### SCRIPT
  band_names <- c(".532nm",".570nm",".650nm",".850nm")
  ##get the list of images that we want from the pano file
  pano_txt <- readLines(pano_file_name) #read text (it is an XML file)
  target_imgs <- str_extract(pano_txt, "filename=.*\\.tif") #Match anything that has a filename =          something    .tif
  target_imgs <- target_imgs[!is.na(target_imgs)] # remove what didnt match the pattern
  target_imgs <- sub("filename=\"","",target_imgs) # remove the "  filename="  " string. The " need to be escaped with the \ to be read as plain text
  
  ##copy the selected images to the output folder
  #setup output folder
  #setup output folder
  output_folder <- tools::file_path_sans_ext(basename(pano_file_name))  # name of folder to move selected images
  full_output_folder <- file.path(dirname(dirname(target_imgs[1])),output_folder, fsep = .Platform$file.sep) #construct "output folder" in the location of the folder of the images
  message("images will be moved to: ", full_output_folder)
  dir.create(full_output_folder, showWarnings = FALSE)
  #move images
  total <- 0 #count them
  tryCatch(
    for (i in target_imgs) {
      #Use every image name (stacked 3 bands) to call the 4 original bands
      for (band in band_names) {
        bname <- gsub("stack\\.",paste0(band,"."),basename(i))
        print(bname)
        #copy if file exists
        if (file.exists(bname)) {
          message("copying: ",bname)
          file.copy(bname, full_output_folder,overwrite = FALSE) #move. This also accepts itself a list tof files to move
          #file.remove(bname) #remove from original location if succesfully copied    
          total <- total + 1
        }
      }

      
    }
    
  )
  message("moved a total of ", total, " images to: ", full_output_folder)
}

#####################################################################################################################################
#### Imageraster calc
#####################################################################################################################################
#Function Kelvin 100 to raster
k2cel <-function(x){(x/100)-273.15}

######################################################################################################################################
#### Save and load images
######################################################################################################################################
## Choose file interactively | *tif file
chooseTif <- function() {
  choose.files(default = "", caption = "Selecciona la imagen",
               multi = FALSE, filters = matrix(c("tif", "*.tif")),
               index = nrow(Filters))}

## Choose multiple files interactively | *tif file
chooseTifs <- function() {
  choose.files(default = "", caption = "Selecciona la imagen",
               multi = TRUE, filters = matrix(c("tif","tiff", "*.tif", "*.tiff")),
               index = nrow(Filters))}


#function to save Gtiff Int to disk
tiffSaveInt <- function(img, name) 
{
  tryCatch({
    #Write the tif to disk
    writeRaster(img, file=name,datatype='INT2U',format="GTiff",overwrite=FALSE)
  })
}


#function to save Gtiff float to disk
tiffSaveFloat <- function(img, name) 
{
  tryCatch({
    #Write the tif to disk
    writeRaster(img, file=name,datatype='FLT4S',format="GTiff",overwrite=FALSE)
  })
}

#function to save Gtiff float to disk
pasteExt <- function(basename, ext) 
{
    #PAste name and extention
    name=paste0(basename,ext)

  return(name)
}

