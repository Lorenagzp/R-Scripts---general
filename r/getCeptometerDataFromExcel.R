####
# ceptimeter sampling data FROM THE EXCEL FIle indicated.fixed format
# STORE TO local DATABASE by par date in a table
####

#library(xlsx)
library(RMySQL)
library(XLConnect)

############################ FUNCTIONS DEFINITION


#########Read Excel sheets
getCeptometerFromExcel <- function (file, startSheet,endCol,endRow,colTypes,col_names,maxsp){
  xlxsF =file
  wb <- loadWorkbook(xlxsF)
  sheets <- getSheets(wb)
  sheets <- lapply(sheets,function(x) tolower(x))
  setMissingValue(wb, value = "NA")
  sheetsIndex <- startSheet:length(sheets)#Avoid the first x sheets of this file because they dont have data
  df.list <- readWorksheetFromFile(xlxsF, #Get the data of th xlsx file
                sheet = sheetsIndex,
                header=TRUE,
                colTypes = colTypes,
                endCol = endCol,
                endRow=endRow)
  #Next just rename the columns
  for (i in 1:length(df.list)){
    colnames(df.list[[i]])<-col_names
  }

  sheets <- sheets[-c(1:(startSheet-1))] #Remove the sheet names that were not used
  
  samplings = length(sheets) # Total sampling dates
  #add date info in  column
  #For every sampling date
  for (s in 1:samplings) {
    df.list[[s]]<-df.list[[s]][df.list[[s]]$id<=maxsp,] #Exclude points above 40 FOR ESCAMILLA etc
    sPoints = length(df.list[[s]]$id) #total samples per date 
    for (i in 1:sPoints) {
      print(paste("sampling",sheets[s],"sample",df.list[[s]]$id[i]))
      df.list[[s]]$date[i] <- as.character(sheets[s]) #add date info in  column
    }
  }
  
  return (list(df.list,sheets))
}

##Replace something in a column of a df list
replaceInCol <- function(df_list,col,txt_orig,txt_replace){
  r_df_list<-df_list
  for(i in 1:length(df_list)){
    print(i)
    l <- length (r_df_list[[i]][,col])
    for(j in 1:l){
      print(j)
      print(df_list[[i]][j,col])
      r_df_list[[i]][j,col] <- gsub(txt_orig, txt_replace, df_list[[i]][j,col])      
    }

  }
  return(r_df_list)
}

################################# EXECUTE SCRIPT
############# INPUTS
file="C://Dropbox//data//AD//AD-STARS//ros//ad_ros_ceptometer.xlsx"
trial <- "ros"
whatData <- "par" #What does this data represent
col_names<-c('id',
              'par',
              'par_time',
              'par_ref',
              'ref_time')
colTypes <- c('numeric', 'numeric', 'character','numeric','character')
maxsp<-25
##Edit next
##getMoistreFromExcel <- function (file, startSheet,endCol,endRow,colTypes,col_names,maxsamplepointID)
mData <- getCeptometerFromExcel(file, 2,5,26,colTypes,col_names,maxsp) #get the moisture data[[1]] and sheetnames[[2]]
############# END INPUTS
##Resulting data
dates<-mData[[2]]
mData <-mData[[1]]

##Replace the data "wrong date" in column 3 to keep the time only
#mData <- replaceInCol(mData,5,"1899-12-31 ","")


##Connecto to local Database
mydb = dbConnect(MySQL(), user='root', password='cimmyt', dbname='ac_stars', host='localhost')
#dbListFields(mydb, 'ros') #List fields on table

#Save moisture data to DB
for(i in 1:length(dates)){
  ##Check if table already exists...
  tExists = dbSendQuery(mydb, paste("SHOW TABLES LIKE '", dates[[i]],"'",sep="")) ##ask if the table exists
  data = dbFetch(tExists, n=-1) #get results. The n=-1 is to get all the results, can be used to set a MAX
  if(length(row.names(data))==0){ #If the table doesnt exists
    print(dates[[i]])
    #withe df to DB
    dbWriteTable(mydb, value = mData[[i]], name = paste(trial,dates[[i]],whatData,sep=""), row.names = FALSE) #THere is an issue vs append and autoincrement index
  }
}

