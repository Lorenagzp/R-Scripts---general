#######
##script to save to Excel lots of CVS in a folder
#######
require(xlsx)
##Set working drectory
setwd("C:/vuelos/ac2015/r")

##Something like this to read all the cvs files
##Another example of use: list.files("C:/temp",full=TRUE)
csv_files = list.files(pattern="*.csv$") #List of the files
DATA <- do.call("rbind", lapply(csv_files,  read.csv, header=TRUE)) #Read them all, like a loop

#Create file
library(xlsx) #load the package
write.xlsx(x = sample.dataframe, file = "test.excelfile.xlsx",
           sheetName = "TestSheet", row.names = FALSE)

#Write to existing file
workbook.sheets
workbook.test
addDataFrame(x = sample.dataframe, sheet = workbook.test,
row.names = FALSE, startColumn = 4) # write data to sheet starting on line 1, column 4
saveWorkbook(workbook.sheets, "test.excelfile.xlsx") # and of course you need to save it.

