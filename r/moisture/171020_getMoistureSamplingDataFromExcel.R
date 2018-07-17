####
# GET MOISTURE SAMPLING FROM THE EXCEL FIle indicated (names of the sheets should be in eg. AR20-11-2015_conv-pre format). used to save the wet and dry weight of the sampling cans
#Calculates the water depth in mm based on the % moisture and using a given formula
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
#set WDir
setwd("C://Dropbox//Software//Scripts//r//moisture")

file="C://Dropbox//Bascula (1)//Muestras suelo//AF//AF-710COMPASS.xlsx"
trial <- "710"
col_names<-c('id',
              'depth',
              'canType',
              'can',
              'wSoilw', #wet soil weight
              'dSoilw', #dry soil weight
              'moisture')
colTypes <- c('numeric', 'character','numeric', 'numeric','numeric','numeric','numeric')
##Check this for every excel read
startRow<- 6 #Skip the fisrt 5 rows because it has other ancillary data
startSheet <- 2
endSheet <- 10
endCol <- 7
endRow <- 66

csvfile <- "C://Dropbox//Bascula (1)//Muestras suelo//AF//AF-710COMPASS.csv"

################################# END INPUTS

##Edit next
##getMoistreFromExcel <- function (file, startSheet,endCol,endRow,colTypes,col_names,maxsamplepointID)
mData <- getMoistreFromExcel(file, startSheet,endSheet,endCol,endRow,colTypes,col_names,startRow) #get the raw moisture data[[1]] and sheetnames[[2]]

##Resulting data
dates<-unlist(mData[[2]])
moistData <-mData[[1]]

#Calculate water table  based on the moisture frome each measurement
samplings = length(dates)
#Use next line to calculate moisture if it is not in the tables
#moistTable1 <- calculateMoist(moistData)
waterLayerTable <- calculateWLayer(moistTable1,dates)

##Bind all samplings in one table (stack the rows, keep the columns)
wLTable <- Reduce(rbind,waterLayerTable)

##FORMATTING
#Format the headers (use if needed)
# wLTable$depth <- gsub('0-15', '1w', wLTable$depth) #replace the depth by an ordered index
# wLTable$depth <- gsub('15-30', '2w', wLTable$depth) #replace the depth by an ordered index
# wLTable$depth <- gsub('30-60', '3w', wLTable$depth) #replace the depth by an ordered index
# wLTable$depth <- gsub('60-90', '4w', wLTable$depth) #replace the depth by an ordered index
wLTable$depth <- gsub('0-15', 'depth1', wLTable$depth) #replace the depth by an ordered index
wLTable$depth <- gsub('15-30', 'depth2', wLTable$depth) #replace the depth by an ordered index
wLTable$depth <- gsub('30-60', 'depth3', wLTable$depth) #replace the depth by an ordered index
wLTable$depth <- gsub('60-90', 'depth4', wLTable$depth) #replace the depth by an ordered index

###########Separate the sheets name into columns (maybe change after the filtering thing?)
#The format should be something like: dr30-11-2015_pre-conv
#sheetname should be in a format dd-mm-yyyy and will have a prefix of 2 char: AR or DR or DT or MV (indicating the kind of sampling: after/before iirgation, etc)
#and a suffix indicating _[pre]/[2R]/[4R]-[1/2/3/4/5]/[pb]/[conv])
#date column - get what has the format of a date dd-mm-yyyy
wLTable$date <- as.Date(regmatches(wLTable$sheetName, regexpr("[0-9]{2}-[0-9]{2}-[0-9]{4}", wLTable$sheetName)),"%d-%m-%Y")
#sampling type column - what looks like [dr]/[ar]/[mv]/[dt] ... (antes de riego, despu?s, verano, trilla...)
wLTable$irrtype <- regmatches(wLTable$sheetName, regexpr("bi|ai|ah|m1", wLTable$sheetName)) #espa?ol ar|dr|mv|dt|m1"
#irrarea sampled column - the sampling corresponded to which irrigation instance: pre(siembra), 4R(4 riegos) or 2R(2 riegos)
wLTable$irrarea <- gsub('_', '',regmatches(wLTable$sheetName, regexpr("_[0-9A-Za-z]+", wLTable$sheetName)))
#irrigation sampled column - weather its the first, second.. irrigation etc
wLTable$irrnum <- gsub('-', '',regmatches(wLTable$sheetName, regexpr("-[0-9A-Za-z]+$", wLTable$sheetName)))

#check for NA's in rows
na_inrow <- apply(wLTable, 1, function(x){any(is.na(x))}) # logical vector of the rows with any NA's
#wLTable <- wLTable[complete.cases(wLTable), ] #This iis to remove any row that has a NA on it.
#keep only the rows that dont have NA's and their treatment correspond to the performed sampling
wLTable <- wLTable[!na_inrow, ]

#Formate the date column to format the axis labels in ggplot
wLTable$date <- as.POSIXct(wLTable$date)

#write the final table to CSV if you want to save to text file
write.csv(wLTable,csvfile, row.names=FALSE)
