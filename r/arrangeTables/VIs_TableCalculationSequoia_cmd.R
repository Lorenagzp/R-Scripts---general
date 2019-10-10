#####################################################################
# Title: ENVI_Indices
# Name: Francisco Manuel Rodriguez Huerta, edited by Lorena González
# Date: 9 Abril 2014, Edit 31/08/2018
# Description: Compute Indices from reflectance band tables in excel, set to be executed from the command line (right clic and send to script with a bat file).
#It can accept multiple input files to execute the tool on each of them. Adapted for the sequoia bands
#####################################################################

### Load required libraries
library(xlsx)
library(stringr)
#get the data processing functions
source((file.path("F:","Dropbox","Software","Scripts","r","functions_data.R", fsep = .Platform$file.sep)))

### set filename of INPUT files
#file<-""   ### get file name fixed mode (this could be actually a list of files)
args <- commandArgs(TRUE) #Get from the command line
#TODO: Filter for only Excel files

### nos posicionamos en el directorio de trabajo ###
#work.dir <- "C:\\pruebas"  ### To Change the input directory manually
work.dir <-dirname(normalizePath(args[1])) #get the WD from the input files
setwd(work.dir) #Set the working directory
getwd() # show the working directory

#Important bands
bandWl <- c(
"R550",
"R660",
"R735",
"R790")

###################
### Calculate indices ###
###################

print("Files to process")

for (arg in 1:length(args)) {
  print(paste0("##### Current file processing...  ", args[arg])) #Print name of file
  #Open the excel file to get the data, read the entire first sheet
  rfl_data <- read.xlsx2(args[arg], sheetIndex = 1,colClasses = c('character',rep('numeric',4)), stringsAsFactors=FALSE)
  print("Data read succesfully")
  colnames(rfl_data) <- c("Plot",bandWl)
  ### Calculate the VIS! (append them to the table)
  rfl_data_VI <- VI_sequoia_tab(rfl_data)
  ## Write the excel file
  print(paste0("writing: ",args[arg],"_VI",".xlsx"))
  write.xlsx(x = rfl_data_VI, file = paste(args[arg],"_VI",".xlsx",sep=""),
             sheetName =   "VI", row.names = FALSE)
  print("###### Success calculating fro this File!")
    #print(rfl_data_VI) Dont print very long tables... it takes very long
}
print("########## Success in execution!")

