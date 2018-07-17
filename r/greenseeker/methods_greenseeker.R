#General functions to process Files, dataframes

#Librearies
library(stringr) #To use str_extract
library(plyr)#Used in: ddply

### GREENSEEKER(GS) ###
#This method will go trhought the input file of readings returning the reading and the corresponding plot: 
#Matching the trial map and the order file
s_order <- function(map, ord, dataNDVI){
  #Allocate the size of the vector to save the order of the plots based on the 
  #way the sampling was done
  #Get the NDVI data
  id_s <- dataNDVI
  #Add a column to set the ID
  id_s$Plot <- ""
  
  #Check if the map has the same dimensions of the "order"
  if( dim(map)[1] == dim(ord)[1] && dim(map)[2] == dim(ord)[2]) {
    #TODO: make this more R-like way
    #Assign the trial plot that corresponds to the reading
    #Go trhough the ndvi samples
    for (s in dataNDVI$Sample_No){
      #Get the array position of the current sample # from the order matrix
      #TODO: Validate unique numbers
      index <- which(ord == s, arr.ind = TRUE) #We get row and column location of the "plot"  (thst is the incremental number) from this sample
      #Assign the corresponding ID of the plot from the map to the sample
      id_s[id_s$Sample_No==s,"Plot"] <- map[index[1,"row"],index[1,"col"] ] 
    }
    return(id_s)
  }
  else{
    #Return empty if sizes dont match
    print("the size of the map and the order file don't match. Check.")
    return(NULL)
  }
}

### GREENSEEKER (GS) ###
# USES: library(stringr)
# the file containing the order of the sampling automatically based on the date of the input NDVI Txt file
#The txt file is expected to have a standard name as: eg. AF_521_080318.txt ~ the date in ddmmyy format
#The expected format of the ord files is: eg. exp021118ord.csv
    # exp == 3 digits for the trial code
    # 021118 == 6 digits for the date in ddmmyy format
    # ord == identifier for the sampling Order file fro the greenseeker sampling
#indicate the directory to look for the file
#Here I will  use the DATE as ddmmyy format because that is how the field guys write the names of the files
get_ordFile <- function(NDVI_txt,path_ord){
  # Get the 6 digit "date".
  date1 <- str_extract(NDVI_txt,"[0123456789]{6}") #Return from the filename what matches the pattern of 6 digits
  #Get the files with CSV extention and that contain the word "ord" somewhere after the date
  ordF <-list.files(path = path_ord,pattern=paste0(date1,"{1}","(ord){1}[[:alnum:]_]*\\.csv$"))
  
  #Return the path + the file location
  return(file.path(path_ord, ordF, fsep = .Platform$file.sep))
}

### Get 6 digit date from filename, based on pattern. very wide search pattern
## Have in mind that it doesnt  take into account if the format is yymmdd or ddmmyy
get6DigitDate <- function(string1){
  date1 <- str_extract(string1,"[0123456789]{6}") 
  return(date1)
}

### GREENSEEKER (GS) ###
#Average the Greenseeker readings (*.txt not the averaged file), get SD, and CV. Group by "Sample_no"
#This are the expected headers:
# Time.ms.  Sample_No   Count    NDVI   VI_2
# NDVI AND Sample_No are NECESSARY
averageNDVI <- function(NDVIreadings){
  ddply(NDVIreadings,~ Sample_No, summarize, 
                 Count =  length(NDVI),
                 Avg_NDVI =  mean(NDVI),
                 Stdev =  sd(NDVI),
                 CV =  sd(NDVI)/mean(NDVI)*100)
}

#Summarize the averaged ndvi readings by treatment
#Several dates are in the table now
averageNDVI_byTreatment <- function(NDVIreadings){
  ddply(NDVIreadings,~ treatment+samp_date, summarize, 
        Avg_NDVI =  mean(Avg_NDVI),
        Avg_Stdev =  mean(Stdev),
        Avg_CV =  mean(CV))
}