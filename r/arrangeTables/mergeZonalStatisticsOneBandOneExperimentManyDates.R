##Script para unir las tablas de NDVI al extraer de las imágenes de varias fechas de una misma area
#Tables are the regular zonal statistics output from arcGIS
# It MUST include the MEAN statistic and an ID field.

#++++++Methods##########################################################
#Libraries
options(java.parameters = "-Xmx30000m") #available RAM for JAVA
library(foreign)
library(xlsx)
library(stringr)
library(plyr)
library(gtools)

#Add the filename to the column name, because all the zonal stats tables have the same column names when from ArcGIS
addFileNameToColumn <- function (f){
  t <- read.dbf(f)
  #filename without extension
  name <- substr(f, 1, nchar(f)-4)
  t <- subset(t, select=c(id,"MEAN"))
  origFields <- colnames(t)
  colnamesB <- origFields
  #Next put the filename column but not in the id column
  for (i in 1:length(colnamesB) ){
    if (colnamesB[i] != id)
      colnamesB[i]<- paste(toString(name), sep="")  
  }
  colnames(t)<- colnamesB
  return (t)
}

#Merge to use with reduce sucessively by "id"
merge.all <- function(x, y) {
  merge(x, y, all=TRUE, by=id)
}

#Merge all "MEAN" columns into one Excel file
arrangeDbf <- function(file_list) {
  #Workbook to save MEAN values
  wbookName <- paste("Data",".xlsx",sep="")
  wbook <- createWorkbook()
  wbSheet <- createSheet(wb = wbook, sheetName = "data")
  
  # batch read all into a addFileNameToColumn
  m.list = lapply(file_list, addFileNameToColumn)
  #merge them into a single data frame
  tables <- Reduce(merge.all, m.list)
  #Next remove the duplicate "id" column
  tables <- tables[,!duplicated(colnames(tables), fromLast = TRUE)]  
  
  #Write to Excel file
  startRow<-1
  print(paste("Escribiendo",nrow(tables),"registros"))
  addDataFrame(x=tables, sheet=wbSheet,row.names=FALSE,startRow = startRow)

  saveWorkbook(wbook, wbookName)
  print(paste("Se guardó el archivo",wbookName))
  return (wbook)
}


#++++++Methods-End##########################################################

#Working Directory
wd<-("C:\\pruebas\\")
setwd(wd)
getwd()
#Id Field to join the tables
id = "Name"

#Get tables
zsTables <-list.files(pattern="\\.dbf$")
#Merge the MEAN column of the tables
xlsx <-arrangeDbf(zsTables)

