##Script to get the descriptive statistics of a table of data
##Reads may csv in working directory with cerain pattern
## Saves the statistics in a TXT in the same location as the data file
##July 2015

#################   Check these inputs#########################
##Set working directory to avoid giving the absolute path of files
##IMPORTANT: use the / slash instead of the backslash \ in the paths
##Or use double backslash \\
wd<-("C:/vuelos/ab2014/Marco/")
setwd(wd)
## Sets the pattern of name in CSV files to be read
data_set = list.files(pattern="vis[0-9]*.csv")
dir.create(paste(wd,"stats/",sep=""))  #Creates a directory to store statistics

#NOTE:#In this script the columns used to get the statistics go from[,6:46]
## because the first 5 have other data like coordinates and lenght
#################   END Check these inputs#########################
#dir() # Lists files in the working directory
#dir.create("C:/test")  #Creates a directory

#Libraries used
library(pastecs)
library(tools)
library(Hmisc)
library(PerformanceAnalytics)

##Load data in CSV format
# name_file_data<- file.choose() #Choose file, save name
# path_wo_extension<-file_path_sans_ext(name_file_data) #save path without extension
# data_basename<-basename(path_wo_extension) #save filename

######### Load protein data #############
##Fixed way, writing the name of file
protein_data_name<- "AB-Marco-protein.csv"
#Next read the data from the protein results file 
##the parameter colClasses specifies to skip the second column of this data
protein_data<-read.csv(protein_data_name, header = TRUE, row.names = 1,colClasses = c("character","NULL","numeric"))
######### END Load protein data #############

###    READ VIS data
##Here read for a CSV with headers and the ID of the entry on the first column
for (i in 1:length(data_set)) {
  #Get names of vis
  vis<-sub("[A-z]*[0-9]*_?","",x=colnames(get(data_set[i])))
  #assigns to variables each of the CSV
  #Select the columns after the 6th one, because the firsts have ancillary data
  assign(data_set[i], read.csv(data_set[i], 
    header = TRUE, row.names = 1,
    colClasses = c("character",rep("NULL",5),rep("numeric",41))))
  ##Descriptive statistics on the data
  data_stats<-stat.desc(get(data_set[i]),basic=TRUE, desc=TRUE, norm=TRUE, p=0.95)
  # Values it returns:
  # nbr.val (the count of values)      
  # nbr.null (the count of null values)     
  # nbr.na  (the count of missing values)     
  # min          
  # max          
  # range        
  # sum          
  # median       
  # mean         
  # SE.mean      
  # CI.mean      
  # var          
  # std.dev      
  # coef.var     
  # skewness     
  # skew.2SE     
  # kurtosis     
  # kurt.2SE     
  # normtest.W   
  # normtest.p 
  
  file_name<-file_path_sans_ext(data_set[i])
  ###########    Graphs     ##############
  pdf(file=paste("stats/",file_name," plots.pdf", sep=""))
  
  #Correlation from Hmisc package: protein vs all vis
  #merge protein & vis tables
  col_to_compare<-merge(data.matrix(protein_data),data.matrix(get(data_set[i])),by="row.names")
  rownames(col_to_compare)<-t(col_to_compare[1])#Set the rownames. traspose the column of rownames to make it match
  col_to_compare<-col_to_compare[,2:length(col_to_compare)]#remove the first column with the rownames
  data_corr<-rcorr(data.matrix(col_to_compare), type="pearson")
  #Chart from PerformanceAnalytics Package
  chart.Correlation(data_corr$r, histogram=FALSE,method = c("pearson"))
  for (j in 1:length(vis)) {
    
    currcolumn_name<-colnames(get(data_set[i])[j])
    currcolumn <-get(data_set[i])[,j]
    par(mfrow=c(2,1))
    #Boxplot
    boxplot(currcolumn, main =paste("Boxplot ",currcolumn_name))
    #histogram
    hist(currcolumn, main =paste("Histogram ",currcolumn_name),xlab = paste(currcolumn_name), nclass = 10)
    #Get median and mean from calculated stats to draw in histogram
    median<-data_stats[8,j] #median. 
    abline(v=median,lty=2,lwd=2,col="blue")
    mean<-data_stats[9,j] #median. 
    abline(v=mean,lty=3,lwd=2, col="red")    
    legend("topleft", legend=c("median","mean"), col=c("blue","red"), lty=c(2,3),lwd=c(2,1))
    
  }
  dev.off();#Finish saving to PDF
  ###########    END  Graphs     ##############
  
  ##Write stats and correlation result to text file
  output_name<- paste(wd, "stats/",file_name, "stats.csv", sep="")
  write.csv(data_stats, file = output_name)
  
  write.csv(data_corr$r, file = paste(wd,"stats/", file_name, "corr.csv", sep=""))
  write.csv(data_corr$r, file = paste(wd,"stats/", file_name, "corr_p.csv", sep=""))
}

# #Example of a function
# f1 <- function(param1,param2){
#   param1*param1+param2
#   }
# a<-f1(param2=2,param1=3)

##Add Quantile data
#data_quantile<-quantile(data$protein)
#write.table(data_quantile, file = output_name, sep = ",", 
#            col.names = FALSE, append=TRUE)

#histogram
#hist(data$protein,xlab = "protein (%)", nclass = 18)

##This is to create an histogram with normal curve from random data
# x <- rnorm(100)
# hist(x, freq=F)
# curve(dnorm(x), add=T)
# 
# h <- hist(x, plot=F)
# ylim <- range(0, h$density, dnorm(0))
# hist(x, freq=F, ylim=ylim)
# curve(dnorm(x), add=T)
