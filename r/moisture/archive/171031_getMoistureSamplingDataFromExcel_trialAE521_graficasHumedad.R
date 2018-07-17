####
# GET MOISTURE SAMPLING FROM THE EXCEL FIle indicated. used to save the wet and dry weight of the sampling cans
#Calculates the water depth in mm based on the % moisture and using a given formula
#This is intended to keep inly the sampling corresponding to the irrigations (no summer samplings)
#and arrange them to plot the moisture levels, and mm of infiltrated water,  across time
#
# regex to split the columns are not robust and the input format should be the same as AD-521 file
#check that the excel sheets's names are formated as: 
# DR16-08-2017_all-4
# DR o AR  > is after or before irrigation
# dd-mm-yyyy
# which plots were sampled: all, conv, 2aux, 4aux, pb
# the # of current irrigation, after or before the sampling was performed (or the preplanting irrigation): 1 2 3 4 pre 
#
#
# Execute a new instance of R to every new file to be processed, to avoid re-using variables
#
# STORE TO local  file
#
# # # # #Check conditions and quality check needed to be implemented
#
# # # # # check Harcoded inputs every time.
#
#Ediciones para leed el AE521
####

#library(xlsx) #preferred to read XLSX?
library("XLConnect")
library(reshape2)
library(ggplot2)
library("dplyr")


####################################################### FUNCTIONS DEFINITION
source(file.path("C:","Dropbox","Software","Scripts","r","moisture","methods_moisture.R", fsep = .Platform$file.sep))

###################################################### EXECUTE SCRIPT
############################### INPUTS

# EDIT NOW
setwd("C://Dropbox//data//AD//AD_nut//521_humedad")
file="C://Dropbox//Bascula (1)//Muestras suelo//AD//AD-521.xlsx"
startSheet <- 5 # CHECK THIS EACH TIME. numbar of sheet of the excel file that has sampling data!! ! ! ! ! ! !! !!! !! ! !! !!! !! ! !! ! ! ! ! ! !
endSheet <- 23#16AE# number of sheets to read starting from the startSheet #!# WTF not working
trial <- "521"
csvfile <- "humedad_AD521.csv"
pnrfile <- "humedad_AD521"

#This is #Fixed for the standard format. Edit otherwise.
col_names<-c('id',
              'depth',
              'canType',
              'can',
              'wSoilw',
              'dSoilw',
              'moisture')
colTypes <- c('numeric', 'character','numeric', 'numeric','numeric','numeric','numeric')
startRow<- 6 #Skip the fisrt 5 rows because it has other ancillary data
endCol <- 7 #Fixed for the standard format
endRow <- 103 #Fixed for the standard format for the trial 521
################################# END INPUTS

##getMoistreFromExcel <- function (file, startSheet,endCol,endRow,colTypes,col_names,maxsamplepointID)
mData <- getMoistreFromExcel(file, startSheet,endSheet,endCol,endRow,colTypes,col_names,startRow) #get the raw moisture data[[1]] and sheetnames[[2]]

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
# wLTable$depth <- gsub('0-15', '1w', wLTable$depth) #replace the depth by an ordered index
# wLTable$depth <- gsub('15-30', '2w', wLTable$depth) #replace the depth by an ordered index
# wLTable$depth <- gsub('30-60', '3w', wLTable$depth) #replace the depth by an ordered index
# wLTable$depth <- gsub('60-90', '4w', wLTable$depth) #replace the depth by an ordered index
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
wLTable$idSum <- substr(sapply(wLTable$id,toString), 2,4)

#check for NA's in rows
na_inrow <- apply(wLTable, 1, function(x){any(is.na(x))}) # logical vector of the rows with any NA's
#wLTable <- wLTable[complete.cases(wLTable), ] #This iis to remove any row that has a NA on it.
#check if the plot corresponds to the performed sampling
irr_corresponds <- wLTable$irrarea == wLTable$irr | wLTable$irrarea == wLTable$till
#keep only the rows that dont have NA's and their treatment correspond to the performed sampling
wLTable <- wLTable[!na_inrow, ]
##Filter the table as DESIRED
#The following is a harcoded way to generate different filterd tables,
#Fro future development this can be converted to a loop or a swith menu.
#wLFiltered <- wLTable[wLTable$irr %in% c("2aux") & wLTable$till %in% c("pb")& wLTable$res %in% c("40%"),] #one way to filter
#wLFiltered <- wLTable[wLTable$irr %in% c("2aux") & wLTable$till %in% c("conv")& wLTable$res %in% c("40%"),] #one way to filter
wLFiltered <- wLTable[wLTable$irr %in% c("4aux")& wLTable$res %in% c("40%"),] #one way to filter, just keeping the  plots/samplings of the 2 auxiliary irrigation scheme

#Summarize the reps 1,2,3 to get just the mean value, of columns wlayer and mositure (put together with the cbind function)
tableSum <- aggregate(cbind(wlayer, moisture) ~ idSum+depth+date+irr+till+res, data=wLFiltered, FUN=mean)

#Formate the date column to format the axis labels in ggplot
tableSum$date <- as.POSIXct(tableSum$date)

### FORMATIING headers ###
#wLTable$date <- substr(wLTable$sheetNames,3,12) #Keep only the date in the column date #!# we actually need the AR/DR 
#wLTable$date <- gsub('201', '1', wLTable$sheetNames) #Replace 4 digits of the year by 2 digit
##format the decimal places of the water layer column to 2 digits, to make cells of same length
##Only format the cells that do have a value, not a NA
#wLTable$wlayer[!is.na(wLTable$wlayer)]  <- format(round(wLTable$wlayer[!is.na(wLTable$wlayer)], 2), nsmall = 2)
##replace Na by a point
#wLTable[is.na(wLTable)] <- "." #use a logical conditional



#Order the data
#wLFiltered <- wLFiltered[order(wLFiltered$depth),] by depth


########convert table to wide format
##Keep the water layer infomation and the IDs
## a "formula object" is used in the  form: varInDependent ~ vardependent
##This fails with duplicate or missing rows
####Here the order of the columns will arrange the table as DESIRED to get a useful format table###################################
#wTable_depth_date <- dcast(wLTable, id + depth ~ irr +area + type, value.var = "wlayer") ##arrange rows by id and columns by depth + date
#wTable_depth_date <- dcast(wLFiltered, id ~ irr +area + type +depth, value.var = "wlayer") ## Arrange for the ASCIIs
#wTable_depth_date <- dcast(wLFiltered, id+date+rep ~ depth  , value.var = "wlayer") ## Arrange for the plots

#30251f,#715A4B,#A78772,#E1B79B

## Plot 
## library(ggplot2)

###Some tricks to format the graph
depthColors <- c(depth1 = "#E1B79B", depth2 = "#A78772", depth3 ="#6d5749", depth4 = "#30251f")
depthColors2 <- c(depth1 = "#8c1a1a", depth2 = "#ed9e36", depth3 ="#008706", depth4 = "#8dc159")
depthColors3 <- c(depth1 = "#ffece0", depth2 = "#ffa474", depth3 ="#db4551", depth4 = "#8b0000")
tillLType <- c(conv = "solid", pb = "longdash")
tillTypeLabel <-c("Conventional","PB")
depthLabel <- c("0-15","15-30","30-60","60-90")
depthPontShape <- c("0-15","15-30","30-60","60-90")
breaks =tableSum$date

#plot the wlayer, group by 2 different variables with "interaction" function
ggplot(data=tableSum, aes(x=date, y=wlayer,group=interaction(idSum,depth))) +  
  #geom_line(aes(color="black",linetype=till))+
  geom_line(aes(linetype=till))+
  geom_point(aes(fill=depth,shape="a"),colour="black",pch=21, size=3)+
  scale_fill_manual(values=depthColors3,labels=depthLabel)+
  scale_linetype_manual(values=tillLType,labels=tillTypeLabel)+
  #scale_linetype_manual(values=tillLType,labels=tillTypeLabel)+ #set the linetype according to the till, list defined
  # to match the secondary axis, the data is "transformed" and then adapted (divide and *)
  ##LABELS
  labs(title="Trial AE-521, Soil water content (2016-2017)",
       subtitle = "4 auxiliary irrigations treatment, 40% residue", 
       x = "Soil sampling date", y = "Water content (mm)") +
  labs(fill = "Depth (cm)",linetype="Tillage")+ #format the legend
  theme(plot.title = element_text(family = "Arial", color="black", face="bold", size=18))+
  theme(plot.subtitle = element_text(family = "Arial", color="black", size=16))+
  theme(axis.title = element_text(family = "Arial", color="black", size=14))+
  #TEMA DE LA GRAFICA
  theme(panel.background = element_rect(fill = "white", colour = "black"))+
  theme(panel.border = element_rect(linetype = "solid", fill = NA))+
  theme(panel.grid.major.y = element_line(colour = "#cccccc"))+
  theme(panel.grid.minor.y = element_line(colour = "#cccccc",linetype="dotted"))+
  scale_y_continuous(minor_breaks = seq(0 , 160, 10))+
  theme(panel.grid.major.x = element_blank())+
  scale_x_datetime(date_breaks = "15 day",date_labels= "%d-%b-%Y")+ #poner la escala en cada 15 d?as
  theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))+
  theme(axis.text = element_text(colour = "black", size=12))

#plot the moisture, group by 2 different variables with "interaction" function
ggplot(data=tableSum, aes(x=date, y=moisture,group=interaction(idSum,depth))) +  
  geom_line(aes(linetype=till))+ #optional color=depth,,size=0.8
  geom_point(aes(fill=depth,shape="a"),colour="black",pch=21, size=3)+
  scale_fill_manual(values=depthColors3,labels=depthLabel)+
  scale_color_manual(values=depthColors3,labels=depthLabel)+
  scale_linetype_manual(values=tillLType,labels=tillTypeLabel)+ #set the linetype according to the till, list defined
  # to match the secondary axis, the data is "transformed" and then adapted (divide and *)
  ##LABELS
  labs(title="Trial AE-521, Soil moisture content (2016-2017)",
       subtitle = "4 auxiliary irrigations treatment, 40% residue", 
       x = "Soil sampling date", y = "moisture (%)") +
  labs(fill = "Depth (cm)",linetype="Tillage")+ #optional ,color = "Depth (cm)
  theme(plot.title = element_text(family = "Arial", color="black", face="bold", size=18))+
  theme(plot.subtitle = element_text(family = "Arial", color="black", size=16))+
  theme(axis.title = element_text(family = "Arial", color="black", size=14))+
  #TEMA DE LA GRAFICA
  theme(panel.background = element_rect(fill = "white", colour = "black"))+
  theme(panel.border = element_rect(linetype = "solid", fill = NA))+
  theme(panel.grid.major.y = element_line(colour = "#cccccc"))+
  theme(panel.grid.minor.y = element_line(colour = "#cccccc",linetype="dotted"))+
  scale_y_continuous(minor_breaks = seq(0 , 160, 2))+
  theme(panel.grid.major.x = element_blank())+
  scale_x_datetime(date_breaks = "15 day",date_labels= "%d-%b-%Y")+
                   #limits = as.Date(c('28-11-2015','12-03-2016')))+ #poner la escala en cada 15 d?as
  theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))+
  theme(axis.text = element_text(colour = "black", size=12))
#save image
namePlot<- "AE521_4aux_40perc_mmWater_PByConv.jpeg"
namePlot<- "AE521_4aux_40perc_moisture_PByConv.jpeg"
ggsave(namePlot)


  ###Example
# ggplot(data=tableSum, aes(x=date, y=wlayer,group=interaction(id, depth))) +  
#   geom_line(aes(color=depth))+
#   geom_point(aes(color=depth))+
#   labs(title = "Soil water content", x = "Date", y = "water layer (mm)")+
#   geom_col(aes(x=date, y=moisture,group=interaction(id, depth)))+
#   scale_y_continuous(sec.axis = sec_axis(~.*2, name = "Moisture (%)"))


##FORMATTING
##split the plot wID into its meaning
#wTable_depth_date$rep <- substr(wTable_depth_date$id,1,1) #Repetition
#wTable_depth_date$irr <- substr(wTable_depth_date$id,2,2) # irrigation
#wTable_depth_date$till <- substr(wTable_depth_date$id,3,3) # till
#wTable_depth_date$residue <- substr(wTable_depth_date$id,4,4) #residue
#wTable_depth_date$nlevel <- substr(wTable_depth_date$id,5,5) # nitrogen level

#And reorder the columns to put the id columns at the begining
#n= length(colnames(wTable_depth_date)) #Count the columns
#wTable_depth_date <- wTable_depth_date[,c((n-4):n,2:(n-5))] #didnt include the first one to omit the full plot name
#FORMATTING: Replace the scores in the headers
#colnames(wTable_depth_date) <- gsub('-', '', colnames(wTable_depth_date))
#colnames(wTable_depth_date) <- gsub('_', '', colnames(wTable_depth_date))

#write the final table to CSV if you want to save to text file
write.csv(wLTable,csvfile, row.names=FALSE)
##write the space delimited file
#How to make the columns stay aligned?
write.table(wTable_depth_date,file = paste(pnrfile,".prn",sep=""),sep = "  ",row.names=FALSE,col.names=FALSE,quote = FALSE)#data
# how to treaspose?# write.table(colnames(wTable_depth_date),file = paste(pnrfile,"header.prn",sep="_"),sep = "  ",row.names=FALSE,col.names=FALSE,quote = FALSE)#header

