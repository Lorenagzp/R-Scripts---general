##Script to get the descriptive statistics of a time series data
##Rearrange the data to have it grouped by VIs
##Reads may csv in working directory with cerain pattern
## Saves the statistics in a TXT in the same location as the data file
##July 2015

#################   Check these inputs#########################
##Set working directory to avoid giving the absolute path of files
##IMPORTANT: use the / slash instead of the backslash \ in the paths
##Or use double backslash \\
wd<-("C:/vuelos/ab2014/Marco/")
setwd(wd)
## Sets the pattern of name in CSV files to be read, save names without extension
data_set = gsub(".csv", "", list.files(pattern="vis[0-9]*.csv"))
#Get dates of the measuremnts
dates<-sub("vis","",x=data_set)

#Load to a dataframe each CSV file with all the VIs per date  
for (i in 1:length(data_set)) {
  #assigns to variables each of the CSV
  #Select the columns after the 6th one, because the firsts have ancillary data
  assign(data_set[i], read.csv(paste(data_set[i],".csv",sep=""), 
    header = TRUE, row.names = 1,
    colClasses = c("character",rep("NULL",5),rep("numeric",41))))
}
#Get names of vis
vis_list<-sub("[A-z]*[0-9]*_?","",x=colnames(get(data_set[i])))

#Create empty dataframe to store re organized data by VI, separately
#vis_data<-data.frame(data.frame(matrix(nrow = 114, ncol = 1)))
#create an array to store all the vis by date
vis_data <- array(0, dim=c(114,10,41), dimnames=c("points","dates","vis")) 

date<-1 #Initialize to use it before the loop
##Loop trough the VIS
for (vi in 1:length(vis_list)) {
  #Name each row as the measurement point
  rownames(vis_data)<-rownames(get(data_set[date]))
  
  ##Loop trough the dates of one VI to store it together
  for (date in 1:length(dates)) {
    
    ##Solution with merge function. Had troubles making it doing the ""join""
    ##withe the row names that start with number but have a letter also, like 5R or 7S
    #vis_data<-merge(vis_data,get(data_set[i])[,j],by="row.names", all = TRUE)
    ##Solution assigning the values to the corresponding column
    vis_data[,date,vi]<-get(data_set[date])[,vi]
  }
  colnames(vis_data)<-dates #Name each column with the date
  
  #################Managed separately
  ##Use this to save results to files (41 VI = 41 files)
  #dir.create(paste(wd,"vis_by_date/",sep=""))  #Creates a directory to store vis by date
  #write.csv(vis_data, file = paste(wd,"vis_by_date/", "VIalldates.csv", sep=""))
  ##Use this to save to a variable
  #assign(paste("VIalldates_",vis[j], sep=""),vis_data)
  
  ##Create empty dataframe to store re organized data by VI (to reset this)
  ##Used with the MERGE alternative 
  #vis_data<-data.frame(data.frame(matrix(NA, nrow = 114, ncol = 1)))
  #####################Managed separately
}
##To find the index which corresponds to a VI in the vis_array:
#match("BGI2", vis)

#### Plot average values of VIS during Cycle to PDF
pdf(file=paste("vis_by_date/"," VIS along cycle.pdf", sep=""))
#par(mfrow=c(7,6))
for (vi in 1:length(vis_list)) {
  #Gets the average of all points by date, this means the meand is applied across the COLUMNS -> MARGIN=2
  plot(1:10, apply(vis_data[,,vis=vi], MARGIN=2, FUN=mean),
    main=vis_list[vi],
    xlab="All 10 image dates")
  
  ##Gets the average of a point "5R" across all dates
  #points(1, mean(vis_data[match("5R", rownames(vis_data)),,vis=vi]), xlab="5R",main=vis[vi])
}
dev.off()#Finish saving to PDF

