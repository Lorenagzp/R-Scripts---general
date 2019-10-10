## Script to get the images corresponding to the area inside a polygon from a folder.
## Assuming the Coordinate system of the geotagg is WGS84
## For RedEdge camera imagery
#April 2019
############################issues arrised. Check code

### Librarys
require(rgdal) #for intersect!
require(exiftoolr) #metadata
require(raster) # To open the shapefile
#require(rgeos) #for intersect?

## Functions

trycatch({
  #### Read ROI polygon
  #### This is where you select the ROI of the areas of interest.
  #### Consider giving a margin in the roi to include images just outide the border that cover well the area
  roi <- shapefile(choose.files(default = "", multi = FALSE, caption = "Select the input  *.shp file", filters = matrix(c("Shapefile","*.shp"),1,2, byrow= TRUE)))  # Returns selected shapefile
  #Reproject to have on the same CRS as the images (assumed to be WGS84)
  roi <- spTransform(roi,CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))
  roi_name <- "roi" # Name to call the subset images.
  
  ##Picture folder location <-> WD
  wd <- choose.dir(caption="Select the folder with the imagery. (Recursive = TRUE)")
  setwd(wd) #set the image folder as the working directory
  
  ## Choose the type of images to work with
  cam <- menu(c("RedEdge","Other"),title = "Choose the type of images to work with", graphics = TRUE)
  ## Proceed depending on the type of imagery
  if (cam == 1){
    
    ## List images in folder. *.tif type is used.
    #you can use the recursive = TRUE parameter if you want to read the subdirectories
    pictures <- list.files(wd,pattern = "\\_1.tif$",recursive = TRUE) #get filenames of the first band
    
  } else if( cam ==2){
    
    ## List images in folder. *.tif type is used.
    #you can use the recursive = TRUE parameter if you want to read the subdirectories
    pictures <- list.files(wd,pattern = "\\.tif$",recursive = TRUE) #get filenames of the first band
    
  }
  
  ##Know the position of each picture
  meta <- exif_read(pictures) #get metadata from files. This takes up to 11 min if there are ~11K pictures from RedEdge camera...
  ##to do: remove images with NA (if error ocurred)++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ EDITING
  ## Get the coordinates and image name for each picture
  imgfileName <- as.data.frame(meta$SourceFile) #filenames of each image
  # This in not working fine apparently but give it a try... filter <- !is.na(imgfileName) #get a boolean list of what is data and what has NA's
  #imgfileName <- imgfileName[filter[,1],] # Remove the records with NA's in the coordinates
  
  lat_long <- as.data.frame(meta[,c("GPSLongitude","GPSLatitude")]) # Data frame of the coordinates
  # lat_long <- lat_long[filter[,1],] #Avoid frames with NAs
  ######### This in not working fine apparently but give it a try... filter2 <- !is.na(lat_long)
  # lat_long <- lat_long[filter2[,1],] #Avoid frames with NAs
  #imgfileName <- as.data.frame(imgfileName[filter2[,1]]) # Remove the records with NA's in the coordinates
  
  ##to do: remove images with NA (if error ocurred) +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Editing ends
  #### Create points based on the coordinates
  img_geotagg <- SpatialPointsDataFrame(lat_long, #Coords
                                        imgfileName, #Data i.e. 
                                        proj4string = CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")) #CRS
  
  # Get points that fall inside the ROI polygon
  in_poly_img <- raster::intersect(img_geotagg, roi) # get point candidates, that match the target ROI polygon area 
  #in_poly_img_list <- as.character(in_poly_img$imgfileName) #list of file names that match
  #in_poly_img_list <- as.character(in_poly_img$`imgfileName[filter2[, 1]]`) #list of file names that match. . ^Having some troubles matching the data types of the functions
  in_poly_img_list <- as.character(in_poly_img$`meta$SourceFile`) #list of file names that match . ^Having some troubles matching the data types of the functions
  message(length(in_poly_img_list)," images are inside the selected polygon ",roi_name)
  
  ## copy in-polygon images to a separate folder
  dir.create(file.path(wd,roi_name, fsep = .Platform$file.sep)) #create folder with the roi name in the same location as the image folder directory
  
  #Copy the images inside ROi to the new folder
  if (cam == 1){## For the RedEdge, I worked only with one band, but want to move all the bands to the new folder
    
    ## copy all 5 bands
    for (i in 1:5) {
      files_copy <- file.copy(gsub("_1.",paste0("_",i,"."),in_poly_img_list), roi_name) #can give this error "more 'from' files than 'to' files" if.. (when the folder is created one level upper than necessary {OR IF SOME IMAGES WERE MOVED?})
      #file.remove (gsub("_1.",paste0("_",i,"."),in_poly_img_list)) #### you can DELETE after copy to "MOVE" the files
      }
    
  } else if( cam ==2){
    
    ## Copy all based on the list to the nes folder
    files_copy <- file.copy(in_poly_img_list, roi_name) #can give this error "more 'from' files than 'to' files" if.. (when the folder is created one level upper than necessary {OR IF SOME IMAGES WERE MOVED?})
    #file.remove (in_poly_img_list) #### you can DELETE after copy to "MOVE" the files
  }

  message(sum(files_copy)," files copied to ", roi_name, " folder")

  },
  error = function(e){print(c("Se produjo un error: ",e$message))},
  warning = function(e){print(paste("Hay advertencias: ", e$message))}
)


#view features
#plot(roi)
#plot(img_geotagg,add=TRUE)