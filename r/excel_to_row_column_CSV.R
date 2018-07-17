# Get field maps by trial in excel format and converto to the format to input in athena's script csv to kml.
#####################################  WORK IN PROGRESSSSS

#Libraries
#library("XLConnect") #For the excels
#library(reshape2) #for the melt

source(file.path("C:","Dropbox","Software","Scripts","r","io_methods.R", fsep = .Platform$file.sep))

####### INPUTS

#Field maps Excels location
fm_folder <- file.path("C:","Dropbox","data","AF","bw","BWOBREGON Y17-18","MAPAS DE SIEMBRA Y17-18", fsep = .Platform$file.sep)
setwd(fm_folder)
#trial to get all sections. Starts with...
trial <- "EYTBWBLHT"

####### SCRIPT

#Get all the excels in the wd that starts with the trial name
xlsx_list <-list.files(pattern= paste0("^",trial,".*\\.xlsx$")) # The \\. is escaping the .'s special char
#Get all the Excel fieldmaps in a table in the "row | col | plot" format
fieldmap_rowcol <- readFieldMapsExcel(xlsx_list)

write.csv(fieldmap_rowcol,file.path("C:","vuelos","temp","fieldmap_rowcol.csv", fsep = .Platform$file.sep), row.names=FALSE)
