#Arrange tables from zonalStatistics Extraction
#Take all the tables from a date-cam and put in one Excel table

# NOT FINISHEDDDDDDDDDDDD

# Used Packages
options(java.parameters = "-Xmx30000m") #available RAM for JAVA
library(foreign)
library(xlsx)
library(stringr)
library(plyr)
library(gtools)

### FUNCTIONS
#Input should be a dbf file 

id="Name" #for AF trials
#id = "id" # For most of the cases
#feature = "buf" ##buf for the BW trials
#feature= "(bfs|b2s)" # for AF trials
feature= "buf" # for AF trials

addFileNameToColumn <- function (f){
  t <- read.dbf(f)
  t <- subset(t, select=c(id,"MEAN")) #select only the MEAN column of the table
  vi <- strsplit(f,split="_")[[1]][2] #Get the VI name from the table name#
  date <- strsplit(f,split="_")[[1]][1] #date
  feature <- strsplit(f,split="_")[[1]][3] #feature
  vi_datefeature <- paste(vi,"_",date,feature, sep="")
  origFields <- colnames(t)
  colnamesB <- origFields
  #Next put the VI name and date in the column but not in the id column
  for (i in 1:length(colnamesB) ){
    if (colnamesB[i] != id)
      colnamesB[i]<- paste(colnamesB[i], vi_datefeature, sep="")  
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
  wbookName <- paste(feature,".xlsx",sep="")
  wbook <- createWorkbook()
  wbSheet <- createSheet(wb = wbook, sheetName = toString(feature)) 
  file_list = list.files(pattern=pattern)#list and filter dbf from ws
  fileList <- mixedsort(file_list)#Natural sorting
  # batch read all into a list
  t.list = lapply(fileList, addFileNameToColumn)
  #merge them into a single data frame
  tables <- Reduce(merge.all, t.list)
  #Next remove the duplicate "id" column
  tables <- tables[,!duplicated(colnames(tables), fromLast = TRUE)]        
  startRow<-1
  print(paste("Escribiendo",nrow(tables),"registros"))
  addDataFrame(x=tables, sheet=wbSheet,row.names=FALSE,startRow = startRow)

  saveWorkbook(wbook, wbookName)
  print(paste("Se guardó el archivo",wbookName))
  return (wbook)
}
#read tables
#################   Check these inputs#########################
wd<-("C:\\Users\\usuario\\Documents\\ArcGIS\\")
setwd(wd)
getwd()

## Sets the pattern of name in files to be stacked
pattern= ".*dbf$" #it will iterate all the tables
xlsx <-arrangeDbf(pattern)