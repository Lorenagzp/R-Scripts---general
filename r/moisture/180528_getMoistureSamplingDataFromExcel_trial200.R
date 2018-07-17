####
# GET MOISTURE SAMPLING FROM THE EXCEL FIle indicated. used to save the wet and dry weight of the sampling cans
#Calculates the water depth in mm based on the % moisture and using a given formula
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
file="C://Dropbox//Bascula (1)//Muestras suelo//AF//AF-200.xlsx" #//AE//AE-521.xlsx

#AD521 endSheet <- 19 leaves out the summer samplings
trial <- "AF-200" #"AD521"
year <- "2017-2018" #"2016-2017"

#This is #Fixed for the standard format. Edit otherwise.
col_names<-c('id','type','canType','can','wSoilw','dSoilw','moisture')
colTypes <- c('numeric', 'character','numeric', 'numeric','numeric','numeric','numeric')
startRow<-4  #Skip the fisrt 5 rows because it has other ancillary data
endRow <- 34 #Fixed for the standard format for the trial 521
endCol <- 7 #Fixed for the standard format
startSheet <- 3 # CHECK THIS EACH TIME. numbar of sheet of the excel file that has sampling data!! ! ! ! ! ! !! !!! !! ! !! !!! !! ! !! ! ! ! ! ! !
endSheet <- 39 # number of sheets to read starting from the startSheet
#info about the "dates" sheet
datesSheetPosition = 40
endColdates=2
endRowdates=38
startRowdates=1


csvfile <- sprintf("%s_%s.csv",trial,variable) #for the output table with the summary

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
################################# END INPUTS

##getMoistreFromExcel <- function (file, startSheet,endCol,endRow,colTypes,col_names,maxsamplepointID)
mData <- getMoistreFromExcel(file, startSheet,endSheet,endCol,endRow,colTypes,col_names,startRow) #get the raw moisture data[[1]] and sheetnames[[2]]

##Resulting data
sheetNames<-unlist(mData[[2]]) #Names from the excel sheets, but they are not standardized for this trial
moistData <-mData[[1]]

#Get the date from Excel sheet list
dates1 <- readWorksheetFromFile(file, sheet = datesSheetPosition,header=TRUE,colTypes="character",endCol = endColdates,
                            endRow=endRowdates,startRow = startRowdates)

##Obtener el número de muestreo que le corresponde a cada fecha
s <- getMoistreFromExcel(file, startSheet,endSheet,6,3,"character","sampling",2)
s <- s[[1]] #Get only the data matrix (because the function returns you also the sheetnames)
s <- Reduce(rbind,s)[,6] #merge them all in one table, stacking the rows
s <- regmatches(s, regexpr("[0-9]{1,2}$", s)) #Return only what looks like 1 or 2 digits (this is our sampling number)
#Add the sampling data to the list of samplings
moistData_n <- mapply(cbind, moistData, "sampling"=s, SIMPLIFY=F)
#Add also the date
moistData_s <- mapply(cbind, moistData_n, "s_date"=as.vector(dates1), SIMPLIFY=F)

#Calculate water table  based on the moisture frome each measurement
#the dates1 is used to "count" th eiterate times, but also adds the date of the sampling to the tables
waterLayerTable <- calculateWLayer0_15(moistData_n,dates1[["dates"]])

##Bind all samplings in one table (stack the rows, keep the columns)
wLTable <- Reduce(rbind,waterLayerTable)

############# Separate the ID to know the treatments
# Get the number of the repetition from the ID
wLTable$rep <- substr(sapply(wLTable$id,toString), 1,1)
# Get the irrigation scheme from the 2rd digit of the ID
wLTable$irr <- substr(sapply(wLTable$id,toString), 2,2)
# Get the nitrogen level fertilization from the 3rd digit of the ID
wLTable$nlevel <- substr(sapply(wLTable$id,toString), 3,3)


# column to summarize the reps, we eliminate the rep ID which is the first char, and also the N level (5th digit)
wLTable$idNoRep <- substr(sapply(wLTable$id,toString), 1,2) # Use for the graphs, dont summarize on the tables

##########Generate and Save graph
tableSum <- aggregate(cbind(wlayer, moisture) ~ irr+nlevel+dates, data=wLTable, FUN=mean)
#Formate the date column to format the axis labels in ggplot
tableSum$dates <- as.POSIXct(tableSum$date)

#plot the wlayer, group by 2 different variables with "interaction" function
ggplot(data=tableSum, aes(x=dates, y=moisture,group=nlevel)) +  #### EDIT HERE !! wlayer/moisture
  geom_line(aes(color=nlevel),size=1)+ #,linetype=till
  facet_grid(irr~.,labeller=labeller(irr = c("1" = "Furrow", "2" = "Drip")))+ #Use this to divide into "panels"
  #geom_point(aes(fill=depthCol,shape="a"),colour="black",pch=21, size=2)+
  #scale_fill_manual(values=depthColors3,labels=depthLabel)+
  #scale_color_manual(values=tillColors,labels=tillTypeLabel)+
  #scale_linetype_manual(values=tillLType,labels=tillTypeLabel)+
  ###Vertical lines to indicate the irrigation, harvest, trilla
  #geom_vline(data = ev, aes(xintercept = as.numeric(fecha)),linetype="dotted")+ 
  #geom_text(data = ev, mapping = aes(label = info, y = 100), angle = 60, hjust = 0)+
  #Anotate to mark the irrigations and planting and harvesting
  #annotate("segment",x = ev[ev$event=="riego","date"],y = 2, xend = ev[ev$event=="riego","date"],
           #yend = 4, color="#0052a5", size=1)+ #yend = 8 for wlayer, 4 for moisture
  #annotate("segment",x = ev[ev$event=="siembra","date"],y = 2, xend = ev[ev$event=="siembra","date"],
           #yend = 4, color="#63a500", size=1)+
  #annotate("segment",x = ev[ev$event=="cosecha","date"],y = 2, xend = ev[ev$event=="cosecha","date"],
           #yend = 4, color="orange", size=1)+

  ##LABELS
   labs(title=sprintf("Trial %s, Soil %s (%s)", trial, variable,year),
       x = "Soil sampling date", y = sprintf("%s (%s)",variable,varUnit)) +
  labs(color="N level")+ #format the legend #,linetype="Tillage"
  # #TEMA DE LA GRAFICA
  theme(plot.title = element_text(family = "Arial", color="black", face="bold", size=18))+
  theme(plot.subtitle = element_text(family = "Arial", color="black", size=16))+
  theme(axis.title = element_text(family = "Arial", color="black", size=14))+
  theme(panel.background = element_rect(fill = "white", colour = "black"))+
  theme(panel.border = element_rect(linetype = "solid", fill = NA))+
  theme(panel.grid.major.y = element_line(colour = "#cccccc"))+
  theme(panel.grid.minor.y = element_line(colour = "#cccccc",linetype="dotted"))+
  scale_y_continuous(minor_breaks = seq(0 , 160, 10))+
  theme(panel.grid.major.x = element_blank())+
  scale_x_datetime(date_breaks = "15 day",date_labels= "%d-%b-%Y")+ #poner la escala en cada 15 d?as
  theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))+
  theme(axis.text = element_text(colour = "black", size=12))
#save image
#output name
namePlot<- paste(trial,variable,".jpg",sep="")
#print(namePlot)
ggsave(namePlot,width = 7, height = 5,dpi=150,units = "in") 
#######End of graph

#check for NA's in rows
na_inrow <- apply(wLTable, 1, function(x){any(is.na(x))}) # logical vector of the rows with any NA's
#keep only the rows that dont have NA's 
wLTable <- wLTable[!na_inrow, ] #the summer samplings are removed innecesarily

#write the final table to CSV if you want to save to text file
write.csv(wLTable,csvfile, row.names=FALSE)
