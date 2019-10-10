#General methods to read and import csv and Excel files
# Editing: Lorena
#thanks to: stackoverflow

library("XLConnect")
library(reshape2) #for the melt in readFieldMapsExcel

readExcel <- function(xlsxFile){
  xlxsF =file
  wb <- loadWorkbook(xlxsF)
  sheets <- getSheets(wb)
  sheets <- lapply(sheets,function(x) tolower(x))
  setMissingValue(wb, value = "NA")
  sheetsIndex <- startSheet:endSheet#Avoid the first 3 sheets of this file because they dont have data
  df.list <- readWorksheetFromFile(xlxsF, #Get the data of th xlsx file
                                   sheet = sheetsIndex,
                                   header=TRUE,
                                   colTypes = colTypes,
                                   endCol = endCol,
                                   endRow=endRow,
                                   startRow = startRow)
}

#Function readFieldMapsExcel to read the field maps that are done in the BW program in MS Excel. A list of their names is passed.
#Usually it is a small number of fieldmap files corresponding to one section, because they need to have unique column numbers.
#It is oriented to format the field map to input in the script Athena did CSVtoKML in python.
#The files need to have all the same size and start and end row and columns of the data in the first sheet of the Excel file.
#the start and end column and row to read from the Excel are defaulted, but can be changed.
#the trial name is expected to be in the last column of the excel file
readFieldMapsExcel <- function(xlsx_list, endCol, endRow,startRow,startCol){
  xlsxs <- list(0)
  for (i in seq_along(xlsx_list)) {
    mapi <- readWorksheetFromFile(xlsx_list[i], sheet = 1,header=TRUE, #we assume all have the same fixed size
                                        endCol = endCol, endRow=endRow,startRow = startRow,startCol=startCol)
    #check for NA's in rows and remove those columns that only have NA's (they belong to an empty column in the field map) or any cell starts with "."
    #This dot filter was because in some fieldmaps the empty rows had dots
    mapi <- mapi[ , !apply(mapi, 2, function(x){all(is.na(x))||any(grepl("^[.]", x))})]  #The apply 1 | 2 parameter is to select to act in rows or columns
    #Now just fix the column name of the trial identifier column. Expected to be the last column (tail function used)
    #TODO: what if it is not the last column?
    colnames(mapi)[colnames(mapi)==tail(colnames(mapi),n=1)] <- "trial"
    mapi$row <- rownames(mapi) ## Add the row number to a column
    #Get all values listed with the column and row corresponding
    #TODO: fix the row |col|plot order from here
    mapi <- melt(mapi, id.vars =c("row","trial"))
    #rename the columnName column 
    colnames(mapi)[3:4] <- c("col","plot")
    #and keep just the number in the columns
    mapi$col <- gsub('X', '', mapi$col)
    #Save the formated fieldmap in the list
    xlsxs[[i]] <- mapi

  }
  
  #Now put all the different fieldmaps in one table
  rowcol_xlsxs <- do.call("rbind", xlsxs)
  #Merge the plot and trial name, separate by underscore
  rowcol_xlsxs$plot <- paste(rowcol_xlsxs$plot,rowcol_xlsxs$trial, sep="/")
  #just order the columns as row |col| plot
  rowcol_xlsxs <-  rowcol_xlsxs[,c(1,3,4)]
  
  #Return value  
  return(rowcol_xlsxs)
}

