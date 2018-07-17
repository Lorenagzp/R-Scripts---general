#Arrange tables from zonalStatistics Extraction
#Take all the tables from a date-cam and put in one Excel table
# Used Packages
options(java.parameters = "-Xmx30000m") #available RAM for JAVA
library(foreign)
library(xlsx)
library(stringr)
library(plyr)
library(gtools)

### FUNCTIONS
###############InputInputInputInputInputInputInputInputInputInputInput
#InputInputInputInputInputInputInputInput
#Input should be a dbf file 

id = "Name" # For most of the cases
feature = "buf" ##buf for the BW trials

#######################################################

addBandToColumn <- function (f){
  t <- read.dbf(f)
  t <- subset(t, select=c(id,"MEAN"))
  band <- str_extract(f, "B[0-9][0-9]*[0-9]*") #Get the band #
  origFields <- colnames(t)
  colnamesB <- origFields
  #Next put the band number in the column but not in the id column
  for (i in 1:length(colnamesB) ){
    if (colnamesB[i] != id)
      colnamesB[i]<- paste(colnamesB[i], band, sep="")  
  }
  colnames(t)<- colnamesB
  return (t)
}
#Merge to use with reduce sucessively by "id"
merge.all <- function(x, y) {
  merge(x, y, all=TRUE, by=id)
}
#stack by-band-dbf statistics in excel
arrangeDbf <- function(pattern) {
  #Name of the workbook will be the camera+date
  cam_date <- substr(pattern, 1, 7)
  wbookName <- paste(cam_date,".xlsx",sep="")
  wbook <- createWorkbook()
  wbSheet <- createSheet(wb = wbook, sheetName = toString(cam_date))
  file_list = list.files(pattern=pattern)#list and filter dbf from ws
  #get mentioned trial names to group them
  trials <- unique(lapply(file_list, function(x) substr(x,8,10)))
  t1=TRUE
  for (tr in trials){
    patt_tr = paste(cam_date,tr,feature,".*",sep="")
    fileListTr <- grep(patt_tr, file_list, value=TRUE)
    fileListTr <- mixedsort(fileListTr)#Natural sorting
    # batch read all into a list
    t.list = lapply(fileListTr, addBandToColumn)
    #merge them into a single data frame
    tables <- Reduce(merge.all, t.list)
    #Next remove the duplicate "id" column
    tables <- tables[,!duplicated(colnames(tables), fromLast = TRUE)]        
    if (t1==TRUE){
      startRow<-1
      print(paste("Escribiendo",nrow(tables),"registros en",tr))
      addDataFrame(x=tables, sheet=wbSheet,row.names=FALSE,startRow = startRow)
      t1<-FALSE
      startRow = startRow+nrow(tables) + 1 #We count that we printed the header line
    }else{
      print(paste("Escribiendo",nrow(tables),"registros en",tr))
      addDataFrame(x=tables,sheet=wbSheet,
                   row.names=FALSE,col.names=FALSE,startRow=startRow)
      startRow = startRow+nrow(tables)
    }
  }
  saveWorkbook(wbook, wbookName)
  print(paste("Se guardó el archivo",wbookName))
  return (wbook)
}
#read tables
#################   Check these inputs#########################
wd<-("C:\\Users\\usuario\\Documents\\ArcGIS\\")
setwd(wd)
getwd()

#change inputs on top

#Get the unique date and camera to stack the  tables
allDbfFiles <-list.files(pattern="\\.dbf$")
date_and_cam <- unique(str_extract(allDbfFiles, "[:alpha:]{1}[:digit:]{6}"))
## Sets the pattern of name in files to be stacked
for (i in date_and_cam){
  print(paste("Fecha y cámara:",i))
  pattern= paste(i,".*dbf$",sep="")
  xlsx <-arrangeDbf(pattern)
}

