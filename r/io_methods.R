#General methods to read and import csv and Excel files

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
readFieldMapsExcel <- function(xlsx_list, endCol = 19, endRow=46,startRow = 2,startCol=3){
  xlsxs <- list(0)
  for (i in seq_along(xlsx_list)) {
    mapi <- readWorksheetFromFile(xlsx_list[1], sheet = 1,header=TRUE, #we assume all have the same fixed size
                                        endCol = endCol, endRow=endRow,startRow = startRow,startCol=startCol)
    mapi$row <- rownames(mapi) ## Add the row number to a column
    
    #Get all values listed with the column and row corresponding
    trial_column <- paste0("Col",endCol-startCol+1) #number of the last column corresponding to the trial
    #TODO: fix the row |col|plot order from here
    mapi <- melt(mapi, id.vars =c("row",trial_column))
    #rename the columnName column and keep just the number in the values
    colnames(mapi)[2:4] <- c("trial","col","plot")
    mapi$col <- gsub('Col', '', long_table$col)
    #check for NA's in rows and remove those rows (they belong to an empty column in the field map)
    na_inrow <- apply(mapi, 1, function(x){any(is.na(x))}) 
    #Save the formated fieldmap in the list
    xlsxs[[i]] <- mapi[!na_inrow, ] 
  }
  
  #Now put all the different fieldmaps in one table
  rowcol_xlsxs <- do.call("rbind", xlsxs)
  #Merge the plot and trial name
  rowcol_xlsxs$plot <- paste(rowcol_xlsxs$plot,rowcol_xlsxs$trial, sep="_")
  #just order the columns as row |col| plot
  rowcol_xlsxs <-  rowcol_xlsxs[,c(1,3,4)]
  
  #Return value  
  return(rowcol_xlsxs)
}

