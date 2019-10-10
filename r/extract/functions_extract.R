### Functions for the extract script "extract_from_raster_based_on_polygon_zones.R"


#############################################################
#### Functions to select specific format files
#### Libraries used:
require(raster) # For importing rasters and shapefile
require(velox) # For fast raster processing
#############################################################

#### Function to choose a CSV file interactively.
##   accepts to set the default location to open in the search window.
askCSV <- function (default){
  f <- choose.files(default = "", multi = FALSE, caption = "Select the input  *.CSV file", filters = matrix(c("CSV File","*.csv"),1,2, byrow= TRUE))
  return(read.csv(f,stringsAsFactors=FALSE))
}

#### Function to choose a shapefile file interactively.
##   accepts to set the default location to open in the search window.
#zones <- readOGR(dsn = fgdb, layer = roi_name) # This can read also GDB features
askSHP <- function (default){
  f <- choose.files(default = "", multi = FALSE, caption = "Select the input  *.shp file", filters = matrix(c("Shapefile","*.shp"),1,2, byrow= TRUE))
  return(shapefile(f)) # Return shapefile filename
}

#### Function to choose a raster file interactively, Allow Tif, Bsq and All
##   accepts to set the default location to open in the search window.}
askRaster <- function (default){
  f <- choose.files(default = "", multi = FALSE, caption = "Select the input raster", filters = matrix(c("BSQ","*.bsq","All","*","Tiff","*.tif"),3,2, byrow= TRUE))
  return(f) # Return raster name 
}

#######################################################################
#### Functions to perform the zonal statistics on multiband rasters
#### Libraries used:
#require(raster) #is already imported in this file
#######################################################################

#### Extract vales from images
extractThis <- function(r_file,zones, outFolder, ID_field ="Name",fun=mean,buf=0){
  ##   Imports raster as stack to allow multiple bands, uses "velox" object to make raster operations faster
  r <- velox(stack(r_file))
  #Set output name like the raster (remove extension and path from), save in the output folder
  OutTableName <- file.path(outFolder,paste0(tools::file_path_sans_ext(basename(r_file)),".csv"),fsep=.Platform$file.sep)
  ## Zonal statistics with velox/raster package 
  #Calculate buffer if necessary, buffer = 0 means no buffer
  if (buf != 0 ) {
    zones <- buffer(zones, width = buf, dissolve= FALSE)
  }
  ## With this we get a table with the values for all the plots and bands
  table <- r$extract(zones, df=TRUE, fun= function(x) fun(x, na.rm = TRUE)) #Perform the extraction with the selected statistic function, remove NA values
  ## Set ID names from the shapefile
  table$ID_sp <- zones@data[,ID_field] 
  #Save to disk
  write.csv(table,OutTableName, row.names = FALSE)
}