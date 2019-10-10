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

#file="C://Dropbox//Bascula (1)//Muestras suelo//AF//AF-710COMPASS.xlsx"
file= choose.files(multi=FALSE)
trial <- "esc"
col_names<-c('id',
              'depth',
              'canType',
              'can',
              'wSoilw', #wet soil weight
              'dSoilw', #dry soil weight
              'moisture')
colTypes <- c('numeric', 'character','numeric', 'numeric','numeric','numeric','numeric')
##Check this for every excel read
startRow<- 1 #Skip the fisrt 5 rows because it has other ancillary data
startSheet <- 1
endSheet <- 20
endCol <- 7
endRow <- 101

csvfile <- "C://Dropbox//AF___esc____moisture.csv"

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
#moistData1 <- calculateMoist(moistData)
waterLayerTable <- calculateWLayer(moistData,dates)

##Bind all samplings in one table (stack the rows, keep the columns)
wLTable <- Reduce(rbind,waterLayerTable)

#check for NA's in rows
na_inrow <- apply(wLTable, 1, function(x){any(is.na(x))}) # logical vector of the rows with any NA's
#wLTable <- wLTable[complete.cases(wLTable), ] #This iis to remove any row that has a NA on it.
#keep only the rows that dont have NA's and their treatment correspond to the performed sampling
wLTable <- wLTable[!na_inrow, ]

#write the final table to CSV if you want to save to text file
write.csv(wLTable,csvfile, row.names=FALSE)
