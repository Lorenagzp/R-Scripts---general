####### Michael%20Dorman-Learning%20R%20for%20Geospatial%20Analysis
setwd("C:\\vuelos\\temp\\") #working directory for tests
myFile = file.path("C:","Dropbox", "data","AE","ae_stars","ae_data_extract.csv", fsep = .Platform$file.sep)
#Get only the file name from a path (with extension)
basename(myFile)
#without extension
library(tools)
tools::file_path_sans_ext("ABCD.csv")
dat = read.csv(myFile, stringsAsFactors = FALSE)
date <- dat$date
#Formatear como fechas las fechas
date <- as.Date(as.character(date),format = "%y%m%d")
  # range_date <- range(date)
  # all_dates <- seq(range_date[1],range_date[2],1)
  # length(all_dates)
  # length(date)
  # which(all_dates %in% date)
#Vector lógico checando cuales fechas son en enero
if_enero <-  date >= as.Date("2017-01-01") & date <= as.Date("2017-1-31")
#porcentaje de las mediciones que fueron hechas en enero
#Todas / las de enero
sum(if_enero)/length(if_enero)
#subset las fechas que pertenecen a enero en base al vector lógico
mediciones_enero <- date [if_enero]
#plot(date, 1:13, type = "l") ## ejemplo de plot línea con fecha de mediciones

#### Otro tema
## Data frames
##CREate one
df = data.frame(
  num = 1:4,
  lower = c("a","b","c","d"),
  upper = c("A","B","C","D"), stringsAsFactors = FALSE)
##Examine the object
str(df)
##Subset a column of the data Frame, but always keep the data frame class
df[ ,3, drop = FALSE]
#Subset with another method, including a conditional, and the names of columns
df[df$lower %in% c("a","d"), c("lower","upper")] ##x %in% table
# Exclude rows that are not complete
df[complete.cases(df),]
##Create a column based on a specific value of a cell (row)
df$word[df$num == 2] <- "two"
## create another column mixing the others
df$mix <- paste(df$num,df$lower,df$upper, sep="")
##Use of ifElse
ifelse(df >= 2, ">2", "menor")
"a" > 2
as.numeric("a")
#get the duplicated values of the vector
u[duplicated(u)]

#####Another subject
###Apply family
#tapply : apply a function across subsets
#data
df$categories <- c("1","1","2","2")
#Get the mean vakue of a column, by groups
#An array is returned
df$mean <- tapply(df$num,df$categories, mean) ##tapply(values, categories, function)
#Eliminate column named "mean"
df <- df[, which(!(colnames(df) %in% "mean"))] #From the logical vector we get the indexes of the columns not named "mean"
#Check for missing values AKA NA's, an array is returned with its names, by group
na_values <- tapply(df$word, df$upper, function (x) any(is.na(x)))
#columns with NA values
names(na_values[na_values])
##use the function apply. It can apply across rows or columns the functions
# parameter with value 1 or 2 refers if it should aggregate rows or columns
#Get the max from num and categories column
apply( df[, c("num","categories")], 2, max, na.rm =TRUE)
#paste values in the row
apply(df, 1, paste)

####Another topic
##Changing between wide and long tables
##Wide tables are the ones which store in columns the different traits measured
## Long tables have format like: a ID / variables / value
library(reshape2)
#Change from wide to long table
long_table <- melt(df, id.vars =c("num","categories"))
#Change back from long to wide table
# a "formula object" is used in the  form: varDependent ~ varIndependent
df <- dcast(long_table, ... ~ variable) # ... means all other variables

#stack dataframes from a list
#Now put all the different fieldmaps in one table
length(do.call("rbind", list.of.df))
rowcol_xlsxs <- mapply(rbind, list.of.df, SIMPLIFY=FALSE) #este creo que no hace eso...

#####  CHECK OUT dplyr and tidyr  !!!!! #####

library(plyr)
##Summarize
## Create new columns by group and making operations
## Transform would append to the same table
df_summ <- ddply(df, .(categories), summarize, 
      nums_max = max(num*num),
      l = length(mix),
      word_ish = word[2],
      sum_mean <- ifelse(categories[1] == 1, sum(num),mean(num)))
##repeat something several times
season = rep(c("winter","spring","summer","fall"), each = 3)
##MAKE A DATA JOIN  !!!!!!
combined = join(df,
                df_summ,
                by = "categories", type = "left", match="all")
#Summarize the reps 1,2,3 to get just the mean value
ts <- aggregate(wlayer ~ noRep+depth+date, data=wLTable, FUN=mean)
##MATRIX
#################################
##create a matrix (2 dimensions)
m <- matrix(1:9,ncol=3, byrow=TRUE)
length(m) #Get lenght
nrow(m) #Get num of rows
ncol(m) #Get num of columns
dim(m) #get dimensions
as.vector(m) # get as linear vector ordered by columns
m[2, , drop = FALSE] #subset second row of the matix and keep the class Matrix
m[2:3, 1:2] = matrix(-1:-4, nrow = 2) #REplace values inside matrix
colMeans(m) # Get the mean values of each column of the matix
apply(m,2,mean) # Get the mean values of each column of the matix, again

##ARRAY N -dimensions!!
#####################################
##Create an array (3 dimensions) 
a = array(1:24, c(2,2,3))
##Create Array that can store values for months of year, weeks, days, and hours of each day. Idea taken from Quora ask.
time_array = array(NA, c(24,7,4,12))
rownames(time_array) <- paste(1:24,":00", sep = "") #set rownames
colnames(time_array) <- c("Lun", "Mar", "Mier","Jue","vier", "sab","dom") #set column names
dimnames(time_array)[[3]] <- c("semana1","semana2", "semana3","semana4") #Set names for the 3 dimension
dimnames(time_array)[[4]] <- paste("mes",1:12, sep = "_") #Set names for the 4th dimension

##Raster!!
######################
library(raster)
#Create a raster
r1 = raster(m) ## the input can be the filepath to an image, the parameter band= n selects a band other than the first
##the function brick can read directly a multiband raster
#Create a raster stack (multispectral raster)
s <- stack(r1, r1)
#Select a susbet of the bands from the stack
s[[1:2]]
nrow(s) ##Get number of rows from layer
nlayers(s) ## Get number of bands
dim(s) ##get dimensions
res(s) ## get the spatial resolution on X and Y
extent(s) ## get the bounds
CRS(proj4string(s)) ## Get the spatial reference, as a Coordinate Reference System Class CRS
##assign Reference system
proj4string(s) <- CRS("+proj=utm +zone=36 +ellps=WGS84 +units=m +no_defs")
names(s) #get the band names
#change band names
names (s) <- c("band1","band2")
hist(s) ## Get the histogram of the bands
writeRaster(s,"C:\\vuelos\\temp\\img.tif",
              format = "GTiff",
              overwrite = FALSE)
## VISUALIZE RASTER
library(rasterVis)
levelplot(s) #plot raster
library(plotKML)
plotKML(s[[1]]) #Export to KML from R
shp <- shapefile("C:\\Dropbox\\data\\AE\\nut\\shp\\521__ae__plt.shp")
plotKML(shp) #Export shapefile to KML from R
## Access raster values as a matrix
s[[1]][1, 1:3] ## raster[[band]][row,column]
## do something with the values
mean(s[[1]][]) ##get the mean of all layer 1
sd(s[[1:2]][]) ##get the sd of all the 2 layers
s[2,2] ##Get all values of a pixel along the bands (matrix)
s[2,2][1,] ## ...in a vector format
## TRansform Raster to matrix or vector
as.matrix(s[[1]])
as.array(s[[1:2]])
## Operations
min(s, na.rm = TRUE) ## Raster of the min values along the bands
min(s[[1]][], na.rm = TRUE) ## value with the min value of first band

######### CHECK CALC(operations on bands) and OVERLAY(between different rasters) functions
ndvi = function(x) (x[2] - x[1]) / (x[2] + x[1]) ##Formula to get NDVI
ndvi_00 = calc(s, fun = ndvi) ## get NDVI from multiband raster with CALC

##Get number of null values in raster band
sum(is.na(s[[1]])[]) #thevalues are transformed to a vector with the []
# Logical rasters can be used as masks and to apply values selectively
temp <- s[[1]]
temp[is.na(temp)] = mean(temp[], na.rm = TRUE) ##Replace NA with the mean value of all
temp[temp < 2] <- 2.5 ## USe a treshold to reassign a value in a raster
#Reclassify values on raster
##Directtly
temp1 <- temp
temp1[temp1 < 5] = -9
temp1[temp1 >= 5] = 1
#plot(temp1)
#hist(temp1)
##Using the reclassify function
temp2 = reclassify(temp, c(-Inf, 4.999, -9, 5, Inf, 1)) ## the ranges are passed as triplets: from, to , newValue

## READ ENVI file as array
library("caTools")
envi <- read.ENVI("h170110escgeo.bsq", headerfile="h170110escgeo.hdr")
asRaster <- brick(envi)
levelplot(asRaster)

#Order the data
dataFrame <- dataFrame[order(dataFrame$column),]

###EGRAPH
# ggplot(data=tableSum, aes(x=date, y=wlayer,group=interaction(id, depth))) +  
#   geom_line(aes(color=depth))+
#   geom_point(aes(color=depth))+
#   labs(title = "Soil water content", x = "Date", y = "water layer (mm)")+
#   geom_col(aes(x=date, y=moisture,group=interaction(id, depth)))+
#   scale_y_continuous(sec.axis = sec_axis(~.*2, name = "Moisture (%)"))

###SPRINTF
#thanks https://www.rdocumentation.org/packages/base/versions/3.4.1/topics/sprintf
## re-cycle arguments
sprintf("%s %d", "test", 1:3)

## Using arguments out of order
sprintf("second %2$1.0f, first %1$1.2f, third %s", pi, 2, "3rd") #2f indica los decimales mostrados

sprintf("min 10-char string '%10s'",
        c("this", "that", "and an even longer one"))

##########
#ggplot
# to match the secondary axis, the data is "transformed" and then adapted (divide and *)
