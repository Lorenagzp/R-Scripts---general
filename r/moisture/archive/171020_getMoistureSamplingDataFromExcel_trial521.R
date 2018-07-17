####
# GET MOISTURE SAMPLING FROM THE EXCEL FIle indicated. used to save the wet and dry weight of the sampling cans
#Calculates the water depth in mm based on the % moisture and using a given formula

#check that the excel sheets's names are formated as: 
# DR16-08-2017_all-4
# DR o AR  > is after or before irrigation
# dd-mm-yyyy
# which plots were sampled: all, conv, 2aux, 4aux, pb
# the # of current irrigation, after or before the sampling was performed (or the preplanting irrigation): 1 2 3 4 pre 
#
# Execute a new instance of R to every new file to be processed, to avoid re-using variables
#
# STORE TO local  file
#
# # # # #Check conditions and quality check needed to be implemented
#
# # # # # check Harcoded inputs every time.
#
####

#library(xlsx) #preferred to read XLSX?
library("XLConnect")
library(reshape2)

####################################################### FUNCTIONS DEFINITION
source(file.path("C:","Dropbox","Software","Scripts","r","moisture","methods_moisture.R", fsep = .Platform$file.sep))


###################################################### EXECUTE SCRIPT
############################### INPUTS
setwd("C://Dropbox//data//AF//nut//data")

file="C://Dropbox//Bascula (1)//Muestras suelo//AF//AF-521.xlsx"
trial <- "521"
col_names<-c('id',
              'depth',
              'canType',
              'can',
              'wSoilw',
              'dSoilw',
              'moisture')
colTypes <- c('numeric', 'character','numeric', 'numeric','numeric','numeric','numeric')
##Check this for every excel read
startRow<- 6 #Skip the fisrt 5 rows because it has other ancillary data
startSheet <- 2
endCol <- 7
endRow <- 102
endSheet <- 17

csvfile <- "waterLayer_humedad_AE521.csv"
pnrfile <- "waterLayer_humedad_AE521"
################################# END INPUTS

##Edit next
##getMoistreFromExcel <- function (file, startSheet,endCol,endRow,colTypes,col_names,maxsamplepointID)
mData <- getMoistreFromExcel(file, startSheet,endSheet,endCol,endRow,colTypes,col_names,startRow) #get the raw moisture data[[1]] and sheetnames[[2]]
##Resulting data
dates<-unlist(mData[[2]])
moistData <-mData[[1]]

#Calculate water table  based on the moisture frome each measurement
samplings = length(dates)
waterLayerTable <- calculateWLayer(moistData,dates)

##Bind all samplings in one table (stack the rows, keep the columns)
waterLayerTableBind <- Reduce(rbind,waterLayerTable)

##FORMATTING
#Format the headers
waterLayerTableBind$depth <- gsub('0-15', '1w', waterLayerTableBind$depth) #replace the depth by an ordered index
waterLayerTableBind$depth <- gsub('15-30', '2w', waterLayerTableBind$depth) #replace the depth by an ordered index
waterLayerTableBind$depth <- gsub('30-60', '3w', waterLayerTableBind$depth) #replace the depth by an ordered index
waterLayerTableBind$depth <- gsub('60-90', '4w', waterLayerTableBind$depth) #replace the depth by an ordered index
#date should be in a format dd-mm-yyyy and will have a prefix of 2 char: AR or DR or DT or MV
waterLayerTableBind$date <- substr(waterLayerTableBind$sheetName,3,12) #Keep only date
waterLayerTableBind$date <- gsub('201', '1', waterLayerTableBind$date) #Replace 4 digits of the year by 2 digit
#format the decimal places of the water layer column to 2 digits, to make cells of same length
#Only format the cells that do have a value, not a NA
waterLayerTableBind$wlayer[!is.na(waterLayerTableBind$wlayer)]  <- format(round(waterLayerTableBind$wlayer[!is.na(waterLayerTableBind$wlayer)], 2), nsmall = 2)
#replace Na by a point
waterLayerTableBind[is.na(waterLayerTableBind)] <- "." #use a logical conditional

#convert table to wide format
#Keep the water layer infomation and the IDs
# a "formula object" is used in the  form: varInDependent ~ vardependent
#This fails with duplicate or missing rows
wTable_depth_date <- dcast(waterLayerTableBind, id ~ depth + date, value.var = "wlayer") ## ... means "all other variables"

##FORMATTING
#split the plot wID into its meaning
wTable_depth_date$rep <- substr(wTable_depth_date$id,1,1) #Repetition
wTable_depth_date$irr <- substr(wTable_depth_date$id,2,2) # irrigation
wTable_depth_date$till <- substr(wTable_depth_date$id,3,3) # till
wTable_depth_date$residue <- substr(wTable_depth_date$id,4,4) #residue
wTable_depth_date$nlevel <- substr(wTable_depth_date$id,5,5) # nitrogen level
#And reorder the columns
n= length(colnames(wTable_depth_date)) #Count the columns
wTable_depth_date <- wTable_depth_date[,c((n-4):n,2:(n-5))] #didnt include the first one
#Replace the scores in the headers
colnames(wTable_depth_date) <- gsub('-', '', colnames(wTable_depth_date))
colnames(wTable_depth_date) <- gsub('_', '', colnames(wTable_depth_date))

#write the final table to CSV if you want to save to text file
write.csv(wTable_depth_date,csvfile, row.names=FALSE)
##write the space delimited file
#How to make the columns stay aligned?
write.table(wTable_depth_date,file = paste(pnrfile,".prn",sep=""),sep = "  ",row.names=FALSE,col.names=FALSE,quote = FALSE)#data
# how to treaspose?# write.table(colnames(wTable_depth_date),file = paste(pnrfile,"header.prn",sep="_"),sep = "  ",row.names=FALSE,col.names=FALSE,quote = FALSE)#header
