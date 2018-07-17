####
# GET MOISTURE SAMPLING FROM THE EXCEL FIle indicated. used to save the wet and dry weight of the sampling cans
#Calculates the water depth in mm based on the % moisture and using a given formula
#This is intended includes summer samplings
#and arrange them to plot the moisture levels, and mm of infiltrated water,  across time, by depths
#
# regex to split the columns are not robust and the input format should be the same as AD-521 file
# regex to split the columns are not robust and the input format should be the same as AD-521 file
#check that the excel sheets's names are formated as: 
# DR16-08-2017_all-4
# DR o AR  > is after or before irrigation
# dd-mm-yyyy
# which plots were sampled: all, conv, 2aux, 4aux, pb
# the # of current irrigation, after or before the sampling was performed (or the preplanting irrigation): 1 2 3 4 pre 
#
#There should be a sheet in the Excel that contains the irrigationdates events standard format (see prev years),
#this should not be included in the sheets that are read to get the data
#
# Execute a new instance of R to every new file to be processed, to avoid re-using variables
#
# STORE TO local  file
#
# # # # #Check conditions and quality check needed to be implemented
#
# # # # # check Harcoded inputs every time.
#
#
####

#library(xlsx) #preferred to read XLSX?
library("XLConnect")
library(reshape2)
library(ggplot2)
library("dplyr")
library(raster)


####################################################### FUNCTIONS DEFINITION
source(file.path("C:","Dropbox","Software","Scripts","r","moisture","methods_moisture.R", fsep = .Platform$file.sep))

###################################################### EXECUTE SCRIPT
############################### INPUTS

# EDIT NOW
setwd("C://Dropbox//data//AF//nut//data") #("C://Dropbox//data//AE//nut//521_humedad")
file="C://Dropbox//Bascula (1)//Muestras suelo//AF//AF-521.xlsx" #//AE//AE-521.xlsx

#AD521 endSheet <- 19 leaves out the summer samplings
trial <- "AF-521" #"AD521"
year <- "2017-2018" #"2016-2017"

#This is #Fixed for the standard format. Edit otherwise.
col_names<-c('id','depth','canType','can','wSoilw','dSoilw','moisture')
colTypes <- c('numeric', 'character','numeric', 'numeric','numeric','numeric','numeric')
startRow<- 6 #Skip the fisrt 5 rows because it has other ancillary data
endRow <- 102 #Fixed for the standard format for the trial 521
endCol <- 7 #Fixed for the standard format
startSheet <- 2 # CHECK THIS EACH TIME. numbar of sheet of the excel file that has sampling data!! ! ! ! ! ! !! !!! !! ! !! !!! !! ! !! ! ! ! ! ! !
endSheet <- 17 # number of sheets to read starting from the startSheet
#info about the "dates" sheet
datesSheetPosition = 18
endColdates=4
endRowdates=24
startRowdates=13

#Info about the graph
#I couldnt iterate the variable because of ggplot, so, set manually:
# REVISE WHEN MAKING A NEW PLOT. This is for labels
variable <- "Moisture" #Or:
#variable <- "Water layer"
varUnit <- "%" #"for the moisture #Or:
#varUnit <- "mm"# for the water layer
#after changing there 2 values you actually only need to re-run the ggplot in lines 147 to 204
########################  # IMPORTANTE  # ############ "#$%#$&%(%&/(/)/())
# Y HAY QUE EDITAR LA LINEA QUE DICE:
# --->>> ggplot(data=tableSum, aes(x=date, y=wlayer,group=interaction(idSum,depth)))
#PARA SELECCIONAR y=wlayer O y=moisture
########################################################  # IMPORTANTE  # ############ "#$%#$&%(%&/(/)/())


csvfile <- sprintf("%s_%s.csv",trial,variable) #for the output table with the summary
################################# END INPUTS

##getMoistreFromExcel <- function (file, startSheet,endCol,endRow,colTypes,col_names,maxsamplepointID)
mData <- getMoistreFromExcel(file, startSheet,endSheet,endCol,endRow,colTypes,col_names,startRow) #get the raw moisture data[[1]] and sheetnames[[2]]
#Get irrigation dates from the excel from the "fechas" spread sheet
ev <- readWorksheetFromFile(file, sheet = datesSheetPosition,header=TRUE,colTypes=rep("character",3),endCol = endColdates,
                            endRow=endRowdates,startRow = startRowdates)
ev[,2] <- as.POSIXct(ev[,2]) #Give the format of date to the column

##Resulting data
sheetNames<-unlist(mData[[2]])
moistData <-mData[[1]]

#Calculate water table  based on the moisture frome each measurement
#length(sheetNames)
waterLayerTable <- calculateWLayer(moistData,sheetNames)

##Bind all samplings in one table (stack the rows, keep the columns)
wLTable <- Reduce(rbind,waterLayerTable)

##FORMATTING
#Format the headers (use if needed)
wLTable$depth <- gsub('0-15', 'depth1', wLTable$depth) #replace the depth by an ordered index
wLTable$depth <- gsub('15-30', 'depth2', wLTable$depth) #replace the depth by an ordered index
wLTable$depth <- gsub('30-60', 'depth3', wLTable$depth) #replace the depth by an ordered index
wLTable$depth <- gsub('60-90', 'depth4', wLTable$depth) #replace the depth by an ordered index

###########Separate the sheets name into columns (maybe change after the filtering thing?)
#The format should be something like: dr30-11-2015_pre-conv
#sheetname should be in a format dd-mm-yyyy and will have a prefix of 2 char: AR or DR or DT or MV (indicating the kind of sampling: after/before iirgation, etc)
#and a suffix indicating _[pre]/[2R]/[4R]-[1/2/3/4/5]/[pb]/[conv])
#date column - get what has the format of a date dd-mm-yyyy
wLTable$date <- as.Date(regmatches(wLTable$sheetName, regexpr("[0-9]{2}-[0-9]{2}-[0-9]{4}", wLTable$sheetName)),"%d-%m-%Y")
#sampling type column - what looks like [dr]/[ar]/[mv]/[dt] ... (antes de riego, despu?s, verano, trilla...)
wLTable$irrtype <- regmatches(wLTable$sheetName, regexpr("ar|dr|mv|dt", wLTable$sheetName))
#irrarea sampled column - the sampling corresponded to which irrigation instance: pre(siembra), 4R(4 riegos) or 2R(2 riegos)
wLTable$irrarea <- gsub('_', '',regmatches(wLTable$sheetName, regexpr("_[0-9A-Za-z]+", wLTable$sheetName)))
#irrigation sampled column - weather its the first, second.. irrigation etc
wLTable$irrnum <- gsub('-', '',regmatches(wLTable$sheetName, regexpr("-[0-9A-Za-z]+$", wLTable$sheetName)))
############# Separate the ID to know the treatments
# Get the number of the repetition from the ID
wLTable$rep <- substr(sapply(wLTable$id,toString), 1,1)
# Get the irrigation scheme from the 2rd digit of the ID, number of irrigation treatment 1 = 2AUX, 2 = 4AUX
wLTable$irr <- substr(sapply(wLTable$id,toString), 2,2)
#use the names of the tillage codes
wLTable$irr[wLTable$irr == 1] <- "2aux"
wLTable$irr[wLTable$irr == 2] <- "4aux"
# Get the type of tillage from the 3rd digit of the ID, Type of tillage 1 = conv, 2 = PB
wLTable$till <- substr(sapply(wLTable$id,toString), 3,3)
#use the names of the tillage codes
wLTable$till[wLTable$till == 1] <- "conv"
wLTable$till[wLTable$till == 2] <- "pb"
# Get the type of residue treatment from the 4rd digit of the ID, 1= 100%, 2=40%
wLTable$res <- substr(sapply(wLTable$id,toString), 4,4)
wLTable$res[wLTable$res == 1] <- "100%"
wLTable$res[wLTable$res == 2] <- "40%"

# column to summarize the reps, we eliminate the rep ID which is the first char, and also the N level (5th digit)
wLTable$idSum <- substr(sapply(wLTable$id,toString), 2,4) # Use for the graphs, dont summarize on the tables

#check for NA's in rows
na_inrow <- apply(wLTable, 1, function(x){any(is.na(x))}) # logical vector of the rows with any NA's
#wLTable <- wLTable[complete.cases(wLTable), ] #This iis to remove any row that has a NA on it.
#check if the plot corresponds to the performed sampling
irr_corresponds <- wLTable$irrarea == wLTable$irr | wLTable$irrarea == wLTable$till | wLTable$irrarea =="all"
#keep only the rows that dont have NA's and their treatment correspond to the performed sampling
wLTable <- wLTable[!na_inrow & irr_corresponds, ] #the summer samplings are removed innecesarily

## Plot 
## library(ggplot2)
auxs <-c("2","4")
residues <-c("100","40")
#variables <- setNames(c("moisture","wlayer"),c("Moisture","Water layer"))#create a vector with names to have the variable and ith units
#variablesString <- setNames(c("%","mm"),c("Moisture","Water layer"))# first are the variables, the second are the names
#!# For future development: make a list of all the parameters to make it more manageable.
#ls <- list(auxs,residues,variables,variablesString)

#Make the graphs of the data making the next combinations
  for(res in residues){
    for(aux in auxs){
      wLFiltered <- wLTable[wLTable$irr %in% sprintf("%saux",aux) & wLTable$res %in% sprintf("%s%%",res),] #one way to filter, just keeping the  plots/samplings of the 2 auxiliary irrigation scheme
      #Summarize the reps 1,2,3 to get just the mean value, of columns wlayer and mositure (put together with the cbind function)
      # Use for the graphs, dont summarize the final tables
      tableSum <- aggregate(cbind(wlayer, moisture) ~ idSum+depth+date+irr+till+res, data=wLFiltered, FUN=mean)
      #Formate the date column to format the axis labels in ggplot
      tableSum$date <- as.POSIXct(tableSum$date)
      
      #plot the wlayer, group by 2 different variables with "interaction" function
      ggplot(data=tableSum, aes(x=date, y=moisture,group=interaction(idSum,depth))) +  #### EDIT HERE !! wlayer/moisture
        geom_line(aes(color=till),size=1)+ #,linetype=till
        facet_grid(depth~.,labeller=labeller(depth = labelsDepth))+ #Use this to divide into "panels"
        #geom_point(aes(fill=depthCol,shape="a"),colour="black",pch=21, size=2)+
        #scale_fill_manual(values=depthColors3,labels=depthLabel)+
        scale_color_manual(values=tillColors,labels=tillTypeLabel)+
        scale_linetype_manual(values=tillLType,labels=tillTypeLabel)+
        ###Vertical lines to indicate the irrigation, harvest, trilla
        #geom_vline(data = ev, aes(xintercept = as.numeric(fecha)),linetype="dotted")+ 
        #geom_text(data = ev, mapping = aes(label = info, y = 100), angle = 60, hjust = 0)+
        annotate("segment",x = ev[ev$event=="riego","date"],y = 2, xend = ev[ev$event=="riego","date"],
                 yend = 4, color="#0052a5", size=1)+ #yend = 8 for wlayer, 4 for moisture
        annotate("segment",x = ev[ev$event=="siembra","date"],y = 2, xend = ev[ev$event=="siembra","date"],
                 yend = 4, color="#63a500", size=1)+
        annotate("segment",x = ev[ev$event=="cosecha","date"],y = 2, xend = ev[ev$event=="cosecha","date"],
                 yend = 4, color="orange", size=1)+
        
        ##LABELS
        labs(title=sprintf("Trial %s, Soil %s (%s)", trial, variable,year),
             subtitle = sprintf("%s auxiliary irrigations treatment, %s%% residue",aux,res), 
             x = "Soil sampling date", y = sprintf("%s (%s)",variable,varUnit)) +
        labs(fill = "Depth (cm)",color="Tillage")+ #format the legend #,linetype="Tillage"
        #TEMA DE LA GRAFICA
        theme(plot.title = element_text(family = "Arial", color="black", face="bold", size=18))+
        theme(plot.subtitle = element_text(family = "Arial", color="black", size=16))+
        theme(axis.title = element_text(family = "Arial", color="black", size=14))+
        theme(panel.background = element_rect(fill = "white", colour = "black"))+
        theme(panel.border = element_rect(linetype = "solid", fill = NA))+
        theme(panel.grid.major.y = element_line(colour = "#cccccc"))+
        theme(panel.grid.minor.y = element_line(colour = "#cccccc",linetype="dotted"))+
        scale_y_continuous(minor_breaks = seq(0 , 160, 10))+
        theme(panel.grid.major.x = element_blank())+
        scale_x_datetime(date_breaks = "30 day",date_labels= "%d-%b-%Y")+ #poner la escala en cada 15 d?as
        theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))+
        theme(axis.text = element_text(colour = "black", size=12))
      #save image
      #output name
      namePlot<- paste(trial,"_",aux,"aux_",res,"perc_",variable,".jpg",sep="")
      #print(namePlot)
      ggsave(namePlot,width = 7, height = 5,dpi=150,units = "in") 
  }
  }

#Graphs #TODO
#this would send all the code to the
#iterateGraph(auxs,residues,variables,variablesString,
#                makeGraphAndSave,tableSum,tableSum$date,tableSum$idSum,tableSum$depth,trial,year)
                                                                                      
#write the final table to CSV if you want to save to text file
write.csv(wLTable,csvfile, row.names=FALSE)
