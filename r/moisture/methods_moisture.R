#Methods for the moisture sampling calculations
#last edited: 27/10/2017

#Library
#library(xlsx) #preferred to read XLSX?
library("XLConnect")
library(reshape2)
library(ggplot2)
library("dplyr")

####################################################### FUNCTIONS DEFINITION
#########Water table calculation
#0-15 cm depth with current sampling settings
#x is the moisture soil percent al 0-100 scale
getwLayer <- function(mperc, depth) {
  switch(depth,
         "0-15" = round((mperc/100)*1.21*15*10, digits = 3),
         "15-30" = round((mperc/100)*1.25*15*10, digits = 3),
         "30-60" = round((mperc/100)*1.44*30*10, digits = 3),
         "60-90" = round((mperc/100)*1.49*30*10, digits = 3))
}

## Function to calculate the Wlayer
calculateWLayer <- function(df.list,sheets) {
  for (s in 1:length(sheets)) {
    #Calculate the water layer for each sample
    sPoints = length(df.list[[s]]$moisture) #total samples per date 
    for (i in 1:sPoints) {
      wl <- getwLayer(df.list[[s]]$moisture[i], df.list[[s]]$depth[i])
      #print result
      #print(paste0("Date ",sheets[s],", plot ",df.list[[s]]$id[i],": wLayer:",wl))
      df.list[[s]]$wlayer[i] <- wl #add water layer info in  column
      df.list[[s]]$sheetName[i] <- as.character(sheets[s]) #add date info in  column
    }
  }
  return (df.list) #data with wLayer info
}

## Function to calculate the Wlayer only at 0-15 depth
calculateWLayer0_15 <- function(df.list,dates1) {
  for (s in 1:length(df.list)) {
    #Calculate the water layer for each sample
    sPoints = length(df.list[[s]]$moisture) #total samples per date 
    for (i in 1:sPoints) {
      wl <- getwLayer(df.list[[s]]$moisture[i], "0-15")
      #print result
      #print(paste0("Date ",sheets[s],", plot ",df.list[[s]]$id[i],": wLayer:",wl))
      df.list[[s]]$wlayer[i] <- wl #add water layer info in  column
      df.list[[s]]$dates[i] <- as.character(dates1[s]) #add date info in  column
    }
  }
  return (df.list) #data with wLayer info
}


#########Read Excel sheets
#The sheet names should be in the format "AR20-11-2015_conv-pre" 
# after or before irrigation, after harvest or summer sampling: AR | DR | DT | MV
# date dd-mm-yyyy
# what trial is measured: conv | pv | 4AUX | 2AUX | all
# number of irrigation: pre | 1 | 2 | 3 | 4 
getMoistreFromExcel <- function (file, startSheet,endSheet,endCol,endRow,colTypes,col_names,startRow){
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
  #Next just rename the columns WITH  the given input names
  for (i in 1:length(df.list)){
    colnames(df.list[[i]])<-col_names
  }
  
  sheets <- sheets[sheetsIndex] #Remove the sheet names that were not used
  
  ##Calculate water table according to the moisture
  #For every sampling date
  #df.list <- calculateWLayer(df.list,sheets)
  
  return (list(df.list,sheets))
}

###Some settings to format the graphs
depthColors <- c(depth1 = "#E1B79B", depth2 = "#A78772", depth3 ="#6d5749", depth4 = "#30251f")
depthColors2 <- c(depth1 = "#8c1a1a", depth2 = "#ed9e36", depth3 ="#008706", depth4 = "#8dc159")
depthColors3 <- c(depth1 = "#ffece0", depth2 = "#ffa474", depth3 ="#db4551", depth4 = "#8b0000")
tillLType <- c(conv = "solid", pb = "longdash")
tillColors <- c(conv = "black", pb = "brown")
tillTypeLabel <-c("Conventional","PB")
depthLabel <- c("0-15","15-30","30-60","60-90")
depthPontShape <- c("0-15","15-30","30-60","60-90")
labelsDepth <- c(depth1 = "0-15", depth2 = "15-30", depth3 ="30-60", depth4 = "60-90")
labelsN200 <- c("1" = "0 N", "2" = "150 N", "3" ="300 N", "4" = "150 N", "5" = "300 N")
#sp + facet_grid(. ~ sex, labeller=labeller(sex = labels))

library(ggplot2)
#Make moisture Graph And Save JPG to working directoy
#Graphs the date vs a variable of the moisture sampling (eg. moisture or water layer mm)
#INPUTS:
#     df        dataframe
#     varCol    data of variable to plot on the Y axis
#     dateCol   data of variable to plot on the X axis
#     idCol     column that has the identifier of the data (data or name?)
#     depthCol  column that has the depth of each sample (data or name?)
#     aux       String of the auxiliary irrigation scheme of the data (for labels)
#     res       String of the residue percent treatment of the data (for labels)
#     trial     String to which trial the data corresponds
#     variable  String of the name of the variable in the Y axis (varCol)
#     year      String of the year cycle
#     varUnit   Sting indicating the units of the variable
makeGraphAndSave <- function(df,varCol,dateCol,idCol,depthCol,aux,res,trial,variable,year,varUnit){
  #plot the wlayer, group by 2 different variables with "interaction" function
  ggplot(data=df, aes(x=dateCol, y=varCol,group=interaction(idCol,depthCol))) +  
  #geom_line(aes(color="black",linetype=till))+
  geom_line(aes(linetype=till))+
  geom_point(aes(fill=depthCol,shape="a"),colour="black",pch=21, size=2)+
  scale_fill_manual(values=depthColors3,labels=depthLabel)+
  scale_linetype_manual(values=tillLType,labels=tillTypeLabel)+
  #scale_linetype_manual(values=tillLType,labels=tillTypeLabel)+ #set the linetype according to the till, list defined
  # to match the secondary axis, the data is "transformed" and then adapted (divide and *)
  ##LABELS
  labs(title=sprintf("Trial %s, Soil %s (%s)", trial, variable,year),
       subtitle = sprintf("%s auxiliary irrigations treatment, %s%% residue",aux,res), 
       x = "Soil sampling date", y = sprintf("%s (%s)",variable,varUnit)) +
  labs(fill = "Depth (cm)",linetype="Tillage")+ #format the legend
  theme(plot.title = element_text(family = "Arial", color="black", face="bold", size=18))+
  theme(plot.subtitle = element_text(family = "Arial", color="black", size=16))+
  theme(axis.title = element_text(family = "Arial", color="black", size=14))+
  #TEMA DE LA GRAFICA
  theme(panel.background = element_rect(fill = "white", colour = "black"))+
  theme(panel.border = element_rect(linetype = "solid", fill = NA))+
  theme(panel.grid.major.y = element_line(colour = "#cccccc"))+
  theme(panel.grid.minor.y = element_line(colour = "#cccccc",linetype="dotted"))+
  scale_y_continuous(minor_breaks = seq(0 , 160, 5))+
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

#######Iterate graph, to use with the "graph Function" makeGraphAndSave
#This can be further improved
#The first are to know how to make the loop
#   auxs            string vector of auxiliary irrigations (just the number)
#   residues        string vector of residues treatments (just the number)
#   variables       named string vector of the variables to be plotted on the Y axis And units to use
#   variablesString named string vector of the variables as "human readable version"
#Examples:
# auxs <-c("2","4")
# residues <-c("100","40")
# variables <- setNames(c("moisture","wlayer"),c("Moisture","Water layer"))#create a vector with names to have the variable (column name in the df) and its units
# variablesString <- setNames(c("%","mm"),c("Moisture","Water layer"))
#######These are just to feed the graph method:
#       (df,varCol,dateCol,idCol,depthCol,aux,res,trial,variable,year,varUnit)
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!needs improvement
iterateGraph <- function(auxs,residues,variables,variablesString, #paramenters to iterate
                         graphFunc,df,dateCol,idCol,depthCol,trial,year){ #parameters to graph (some are already implicit in the iterate parameters)
  #Make the graphs of the data making the next combinations
  for(var in names(variablesString)){ 
    #indicate the units of the variable
    varUnit <-variablesString[var] #get the units from the names vector
    for(res in residues){
      for(aux in auxs){
        ##Filter the table as DESIRED
        #The following is a harcoded way to generate different filterd tables,
        #Fro future development this can be converted to a loop or a swith menu.
        wLFiltered <- wLTable[wLTable$irr %in% sprintf("%saux",aux) & wLTable$res %in% sprintf("%s%%",res),] #one way to filter, just keeping the  plots/samplings of the 2 auxiliary irrigation scheme
        #Summarize the reps 1,2,3 to get just the mean value, of columns wlayer and mositure (put together with the cbind function)
        # Use for the graphs, dont summarize the final tables
        tableSum <- aggregate(cbind(wlayer, moisture) ~ idSum+depth+date+irr+till+res, data=wLFiltered, FUN=mean)
        #Formate the date column to format the axis labels in ggplot
        tableSum$date <- as.POSIXct(tableSum$date)
        
        #Select variable name
        variableCol <-variables[var]
        
        #Graph the data
        graphFunc(df,df[variableCol],dateCol,idCol,depthCol,aux,res,trial,var,year,varUnit)
        #Next just to check the loop
        #print(sprintf("Variable is %s in %s, %s%% residue and %saux - varCol %s",var,varUnit,res,aux,variableCol))
        #print(paste(aux,res,trial,var,year,varUnit))
      }
    }
  }
}
