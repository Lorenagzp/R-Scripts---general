library("XLConnect")


source(file.path("C:","Dropbox","Software","Scripts","r","moisture","methods_moisture.R", fsep = .Platform$file.sep))
source('F:/Dropbox (RSG)/Software/Scripts/r/functions_data.R')

setwd("F:/Dropbox (RSG)/data/AB/Hyper data 62b")
#Get the unique date and camera to stack the  tables
allFiles <-list.files(pattern="\\.xlsx$")

for (i in allFiles){
  print(paste("File:",i))
  table  <- readWorksheetFromFile(i, sheet = 1,header=TRUE)
  table_ <-sepatateFirstColumn521(table,"code")
  message("save",i)
  namefile <- substr(i,1,nchar(i)-5) #Remove the .XLSX extention
  write.csv(table_, paste0(namefile,".csv"),row.names = FALSE)
}

