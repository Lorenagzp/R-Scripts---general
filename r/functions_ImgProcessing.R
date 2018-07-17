#functions for image processinh

require(raster)

#Para agarrar las 4 bandas de reflectancia de la sequoia y unirlas en un archivo
stackSeq <- function(name,path){
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



require(rgdal)

# Read the feature class
get_feature <- function(feature,database) {readOGR(dsn=database,layer=feature)}
# Read a shapefile
get_shape <- function(shape,path){readOGR(dsn = path, layer = shape)}