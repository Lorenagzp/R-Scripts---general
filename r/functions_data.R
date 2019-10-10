# Functions for general data processing, importing, calculating, etc

###############################################################################################
################ Vegetation indexes on Tables - STRUCTURAL INDEXES
#Function to calculate NDVI from a table of band reflectances of the MCA camera. Need to have the band colnames named as used here
VI_MCA_tab <- function(rfl6_table, VI) 
{
  tryCatch({
    ### Get the band data
    R550 <- as.numeric(rfl6_table[,"R550"]) #B1, Rfl 550 nm
    R670 <- as.numeric(rfl6_table[,"R670"]) #B2, Rfl 670 nm
    R700 <- as.numeric(rfl6_table[,"R700"]) #B3, Rfl 700 nm
    R710 <- as.numeric(rfl6_table[,"R710"]) #B4, Rfl 710 nm
    R750 <- as.numeric(rfl6_table[,"R750"]) #B5, Rfl 750 nm
    R800 <- as.numeric(rfl6_table[,"R800"]) #B6, Rfl 800 nm
    
    #VI formulas
    #Structural Indices
    #GNDVI (R800-G)/(R800+G)
    #NDRE (R800-RE)/(R800+RE)
    rfl6_table$NDVI <- (R800-R670)/(R800+R670)
    rfl6_table$RDVI <- (R800-R670)/sqrt(R800+R670)
    rfl6_table$OSAVI <- (1+0.16)*(R800-R670)/(R800+R670+0.16)
    rfl6_table$SR <- R800/R670
    rfl6_table$MSR <- ((R800/R670)-1)/sqrt(R800/R670)+1
    #rfl6_table$MTVI1 <- 1.2*(1.2*(R800-R550)-2.5*(R670-R550))
    rfl6_table$MCARI1 <- 1.2*(2.5*(R800-R670)-1.3*(R800-R550))
    rfl6_table$MCARI2 <- (1.5/1.2)*(1.2*(2.5*(R800-R670)-1.3*(R800-R550)))/sqrt((2*R800+1)^2-(6*R800-5*sqrt(R670))-0.5)
    #rfl6_table$MTVI2 <- (1.5/1.2)*(1.2*(1.2*(R800-R550)-2.5*(R670-R550)))/sqrt((2*R800+1)^2-(6*R800-5*sqrt(R670))-0.5)
    
    #Chlorophyll indices
    rfl6_table$TVI <- 0.5*(120*(R750-R550)-200*(R670-R550))
    rfl6_table$GM1 <- R750/R550
    rfl6_table$PSSRa <- R800/R670
    rfl6_table$MCARI <- ((R700-R670)-0.2*(R700-R550))*(R700/R670)
    rfl6_table$TCARI <- 3*((R700-R670)-0.2*(R700-R550))*(R700/R670)
    rfl6_table["TCARI/OSAVI"] <- (3*((R700-R670)-0.2*(R700-R550))*(R700/R670))/((1+0.16)*(R800-R670)/(R800+R670+0.16))
    rfl6_table["MCARI/OSAVI"] <- (((R700-R670)-0.2*(R700-R550))*(R700/R670))/(1+0.16)*(R800-R670)/(R800+R670+0.16)
    
    #RGB indices
    rfl6_table["R550/R670"] <- R550/R670 # G
    rfl6_table["R700/R670"] <- (R700/R670) #R
    
    #Red edge ratios
    rfl6_table["R750/R710"] <- (R750/R710)
    rfl6_table["R750/R700"] <- (R750/R700)
    rfl6_table["R750/R670"] <- (R750/R670)
    rfl6_table["R710/R700"] <- (R710/R700)
    rfl6_table["R710/R670"] <- (R710/R670) 
    
    
    
    print("VIs calculated succesfully")
    return(rfl6_table)
  })
}

###############################################################################################
################ Vegetation indexes on Tables - STRUCTURAL INDEXES
#Function to calculate NDVI from a table of band reflectances of the sequoia camera. Need to have the band colnames named as used here
VI_sequoia_tab <- function(rfl4_table) 
{
  tryCatch({
    ### Get the band data
    R550 <- as.numeric(rfl4_table[,"R550"]) #B1, Rfl 550 nm
    R670 <- as.numeric(rfl4_table[,"R660"]) #B2, Rfl 660 nm ## approx match
    R750 <- as.numeric(rfl4_table[,"R735"]) #B3, Rfl 735 nm ## approx match
    R800 <- as.numeric(rfl4_table[,"R790"]) #B4, Rfl 790 nm ## approx match
    
    #VI formulas
    #Structural Indices
    rfl4_table$NDVI <- (R800-R670)/(R800+R670)
    rfl4_table$RDVI <- (R800-R670)/sqrt(R800+R670)
    rfl4_table$OSAVI <- (1+0.16)*(R800-R670)/(R800+R670+0.16)
    rfl4_table$MSR <- ((R800/R670)-1)/sqrt(R800/R670)+1
    #rfl4_table$MTVI1 <- 1.2*(1.2*(R800-R550)-2.5*(R670-R550))
    rfl4_table$MCARI1 <- 1.2*(2.5*(R800-R670)-1.3*(R800-R550))
    rfl4_table$MCARI2 <- (1.5/1.2)*(1.2*(2.5*(R800-R670)-1.3*(R800-R550)))/sqrt((2*R800+1)^2-(6*R800-5*sqrt(R670))-0.5)
    #rfl4_table$MTVI2 <- (1.5/1.2)*(1.2*(1.2*(R800-R550)-2.5*(R670-R550)))/sqrt((2*R800+1)^2-(6*R800-5*sqrt(R670))-0.5)
    
    #Chlorophyll indices
    rfl4_table$TVI <- 0.5*(120*(R750-R550)-200*(R670-R550))
    rfl4_table$GM1 <- R750/R550
    rfl4_table$PSSRa <- R800/R670

    #RGB indices
    rfl4_table["R550/R670"] <- R550/R670 # G
    
    #Red edge ratios
    rfl4_table["R750/R670"] <- (R750/R670)
    
    
    print("VIs calculated succesfully")
    return(rfl4_table)
  })
}
###############################################################################################
################ Table changes

#### Function to divide the values of a table by a certain value, 
#### It is assumed that the first column is the identifier
divideMCA6Table <- function(table1,divisor) 
{
  tryCatch({
    ### divide from the second on columns
    table_divided <- table1
    table_divided[,2:7] <- table1[,2:7]/divisor #################################################################################################################################################### Work in progress
    print("Divided succesfully - to get the 0-1 Range of the reflectance")
    return(table_divided)
  })
}

##Separate and replace the ID code of the 521 into: REP IRR TILL RESIDUE NLEVEL
#INPUT: a dataframe with the code on the first column
sepatateFirstColumn521 <- function(table,IDFieldName){
  
  tryCatch({
    ##Know the number of columns
    ncols_original <- ncol(table)
    
    table$REP <- substr(sapply(table[,IDFieldName],toString), 1,1) #I had to convert to string to split the name
    table$IRR <- substr(sapply(table[,IDFieldName],toString), 2,2)
    table$TILL <- substr(sapply(table[,IDFieldName],toString), 3,3)
    table$RESIDUE <- substr(sapply(table[,IDFieldName],toString), 4,4)
    table$NLEVEL <- substr(sapply(table[,IDFieldName],toString), 5,5)
    
    ##Reorder the tables
    ##Know the number of columns now
    ncols <- ncol(table)
    ## The added columns start in
    addedCols <- ncols_original+1
    ##We added 6 at the end so, we will bring them at the beginging
    table <- table[,c(1,addedCols:ncols,2:ncols_original)]
    return(table)
  })
}

##function to join a set of text files with the same structure to one single table, stacking them one after another (ordering the file names) and saves to csv file 
require("gtools")
join_txt_files <- function(workingdirectory,pattern="*\\.txt"){
  
  temp = mixedsort(list.files(workingdirectory,pattern=pattern)) # read the filenames and order them
  myfiles = lapply(temp, read.csv) ##"read all the files"
  df <- do.call("rbind", myfiles) ##merge in one table
  write.csv(df,file.path(workingdirectory,"files_merged.csv")) ##write output table
  
  return(df)
}