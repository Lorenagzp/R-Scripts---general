##Script to get the descriptive statistics of a table of data
##the column used to get the statistics is called "protein"
##You can replace "protein" to get the statistics from a different value in the table
## Saves the statistics in a TXT in the same location as the data file
##July 2015

##Set working directory to avoid giving the absolute path of files
##IMPORTANT: use the / slash instead of the backslash \ in the paths
##Or use double backslash \\
setwd("C:/vuelos/ab2014/Marco")
#dir() # Lists files in the working directory
#dir.create("C:/test")  #Creates a directory

#Libraries used
library(pastecs)
library(tools)

##Load data in CSV format
#name_file_data<- file.choose()#Interactive choose file
data_basename<-basename(file_path_sans_ext(name_file_data))
##Fixed way, writing the name of file
name_file_data<- "AB-Marco-protein.csv"
##Here is for a CSV with headers and the ID of the entry on the first column
#data<-read.csv(file = name_file_data, header = TRUE, row.names = 1)
##Interactive way where you can select the file
data<-read.csv(name_file_data, header = TRUE, row.names = 1,colClasses = c("character","NULL","numeric"))


##Descriptive statistics on the data
data_stats<-stat.desc(data,basic=TRUE, desc=TRUE, norm=TRUE, p=0.95)
data_stats
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

##Quantile
data_quantile<-quantile(data$protein)

#Graphics to save to PDF
pdf(file=paste("stats/",file_name," plots.pdf", sep=""))
par(mfrow=c(2,1))
#Boxplot
boxplot(data, main =paste("Boxplot ","protein"))
#histogram
hist(data, main =paste("Histogram protein"),xlab = "protein (%)", nclass = 20)
#Get median and mean from calculated stats to draw in histogram
median<-data_stats[8,1] #median. 
abline(v=median,lty=2,lwd=2,col="blue")
mean<-data_stats[9,1] #median. 
abline(v=mean,lty=3,lwd=2, col="red")    
legend("topleft", legend=c("median","mean"), col=c("blue","red"), lty=c(2,3),lwd=c(2,1))
dev.off();
#Finish saving to PDF

##Write result to text file
output_name<- paste(data_basename, "stats.csv", collapse = NULL)
write.csv(data_stats, file = output_name)
#Add quartile data to previous file
q<-c("value")
names(q)<-c("Quantiles_perc")
write.table(q, file = output_name, sep = ",", 
            col.names = FALSE, append=TRUE)
write.table(data_quantile, file = output_name, sep = ",", 
            col.names = FALSE, append=TRUE)

##This is to create an histogram with normal curve from random data
# x <- rnorm(100)
# hist(x, freq=F)
# curve(dnorm(x), add=T)
# 
# h <- hist(x, plot=F)
# ylim <- range(0, h$density, dnorm(0))
# hist(x, freq=F, ylim=ylim)
# curve(dnorm(x), add=T)
