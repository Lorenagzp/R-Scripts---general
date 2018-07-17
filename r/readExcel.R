#General file to read exel with data from #Bascula

source(file.path("C:","Dropbox","Software","Scripts","r","io_methods.R", fsep = .Platform$file.sep))

#Set the WD
setwd(choose.dir(default = file.path("C:","Dropbox", fsep = .Platform$file.sep), caption = "Select folder"))

#Choose the file interactively
file_options <-matrix(c("Excel","Excel","*.xls","*.xlsx"), nrow = 2,ncol = )
f <- choose.files(filters = file_options)

wb <- loadWorkbook(f)
alfo <- readWorksheetFromFile(wb)
