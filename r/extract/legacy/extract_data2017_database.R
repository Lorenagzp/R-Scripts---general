## Script to extract values from imagery
## Input files are indicated in a Postgres table
## Lorena 2017
########################################## WORK in progressssssssssssssssssssssssssssssssssssss !"#$&$%/&(/)&/()&"

#Special comments
#.# this is very specific to this data
#!# Error code or work in progress

############################LIBRARIES
library(plyr)
library (raster)
library(rgdal)
library(reshape2)
require("RPostgreSQL")
library("caroline")

####Fixed things}
##The drive where the imagery is located
baseDir <- file.path("G:","AE", fsep = .Platform$file.sep)
#setwd(baseDir)

############################FUNCTIONS

#Function to check if file exists
#!# 

##############################SCRIPT

##<<<<<<<<<<<<<<<<# Connect to database {
##based on r-bloggers.com getting-started-with-postgresql-in-r
# install.packages("RPostgreSQL")
#require("RPostgreSQL")

# create a connection to  a DB in postres
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
  "cimmyt"
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
# here the connection values should be specified
connection <- dbConnect(drv, dbname = "ceneb_nut",
                 host = "localhost", port = 5432,
                 user = "postgres", password = pw)
rm(pw) # removes the password

# check for the table "capture" to test connection
dbExistsTable(connection, "capture")
# TRUE means there is connection

# fetch the data from postgreSQL #capture" table
df_capture <- dbGetQuery(connection, "SELECT * from capture") #Returns a dataframe type

# close the connection when finished
dbDisconnect(connection)
dbUnloadDriver(drv)
##>>>>>>>>>>>>>#  } connection to DB losed

##Select values of interest to extract
#only the ones that meet the required criteria
#.# get the rows which "extract_now" == 1, keep all columns (but "extract_now")
log <- df_capture[df_capture$extract_now %in% 1 & df_capture$sensor %in% c("t","h"), 1:5]
#this just to get the date format I want
log$date <- gsub("-", "", log$cap_date, fixed = TRUE) #.#
log$date <- gsub("^2017", "17", log$date) #.# ^ is to represent the begining of the string

#This df will be to query the extension & suffix of the raster depending on the camera
#Cam values could be factors... 
###############!########## thisshould be imported from the Database as well
img_notes <- data.frame("sensor"=c("t","h"),
                        "ext"=c(".tif",".bsq"),
                        "sfx" =c("geo","geo"),
                        "folder" =c("geo","rfl_spr_ort_geo"),
                        "nBands" = c(1,62),
                        stringsAsFactors = FALSE)

#Now we need to be able to form the location of the imagery
#we add the img_notes to the log, based on the sensor
log <- join(log,
             img_notes,
             by = "sensor", type = "left", match="all")
#Put the info from ("sensor","date","area","processing stage suffix","extention") together
img_names <- apply(log[,c("sensor","date","area","sfx","ext")],1,paste,collapse="") #one way to paste all the values by row
img_paths <- paste(log$date,log$sensor,log$folder,sep=.Platform$file.sep) #another way to paste values in the same row
img_lists <- paste(baseDir,img_paths,img_names,sep=.Platform$file.sep)

#Check files that exist and not
# Yes exist
files_exist <- img_lists[file.exists(img_lists)]
#length(files_exist)
# Does not exist, allows to check what happened
files_not_exist <- img_lists[!file.exists(img_lists)]

############### #!# EXTRACT (still work in progress)

#To extract the data we need the location of the plot polygons
#!# This should be taken from the spatial database
#.# For now this is hardcoded

##import the shapefile of sampling points of the experiments
shp_esc <- shapefile("C:\\Dropbox\\data\\AE\\ae_stars\\esc\\shp\\esc__ae__pts.shp")
shp_ser <- shapefile("C:\\Dropbox\\data\\AE\\ae_stars\\ser\\shp\\ser__ae__pts.shp")
shp_ros <- shapefile("C:\\Dropbox\\data\\AE\\ae_stars\\ros\\shp\\ros__ae__pts.shp")

## if you wanted to save a shapefile:
#writeOGR(obj=file_to_be_saved, dsn="algo", layer="file_to_be_saved", driver="ESRI Shapefile")

#Next extract the mean values of the raster at the point locations, using a buffer, ignore noData
#!# 
##the parameter "layer" is potentially useful to append the result to the shapefile table
buff = 1.5 ##Seleccionar tamaño de buffer. Units are the projection units -> meters
######## HARDCODED FOR TESTS#.#
img <- stack(img_lists[15])## create the raster stack from the image name(stack because its mutispectral) #!#
#Extraction execution
table <-extract(img,shp_ser, buffer=buff,fun = mean, df =TRUE, na.rm = TRUE) #this takes around 5 min to run each image
rm(img) # Remove the raster stack from memory after use to avoid overload

#################################### data manupulation
#!#  # # # # # Missing to implement quality checks here of the data
## Rename column names (with the band information) to simplify them
nBands <- img_notes$nBands[img_notes$sensor == "h"] ###################!!!!!!!!!!!#!#!!######.###### HARDCODED h
names(table) <- c("ID", seq(1,nBands)) ###################!!!!!!!!!!!#!#!!######.###### HARDCODED. Here I should know how many band there are depending on the sensor
#Change from wide to long table to manage better the different number of bands
table1 <- melt(table, id.vars = "ID") #####!### where did ID come from???
table1$trial <- "esc" ###################!!!!!!!!!!!#!#!!######.###### HARDCODED
table1$date <- "2017-01-23" #############!!!!!!!!!!!#!#!!######.###### HARDCODED
table1$sensor <- "h" ####################!!!!!!!!!!!#!#!!######.###### HARDCODED


#!# # # # ########## SAVE DATA to DB (still work in progress)


# add rows to the PostgreSQL database , table "capture" 
#library("caroline") #!# NEED to CHECK THIS, cant make  it insert values iin a table with a serial type
#!# NEED to CHECK THIS
#
#max_id <- dbGetQuery(connection, "select max(id) from measurement")  #Returns a last position for the serial
#max_id <- max_id +1
#class(max_id)
#rows <- nrow(table1)
#table1$serial_test <- seq(max_id+1,rows)################!!!!!!!!!!!#!#!!######.###### HARDCODED. serial test
#
#df <- table1[,c("serial_test","ID","trial","date","sensor","value","variable")]
#names(df) <- c("id", "plot_msure","trial_msure","date_msure","sensor_msure","value_msure","variable_msure")

#dbWriteTable(connection, "measurement", value = df, append=TRUE,row.names=FALSE)


#!# # # # ########## EDN SAVE DATA to DB (still work in progress)
