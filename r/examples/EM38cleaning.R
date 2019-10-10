#######
##Clean EM38 data: normalize and Standardize
## Input format: CSV file with columns: "x_utm" "y_utm" "elev" "CV_1" "CV_05" "IV_1" "IV_05" 
#######

#Libraries used
library(pastecs)
library(tools)

##INPUTS###########################################################
##Set working drectory
setwd("C:\\Dropbox\\data\\AF\\bw\\em38\\blockD171121\\raw")
##Input file CSV
name_file_data<- "bw_d_171121_withoutTurns_cleaned.csv"

##Script###########################################################
basename_file_data <- strsplit(name_file_data, "\\.")[[1]]#name without extension
basename_file_data<-basename_file_data[1]
##Name to store the cleaned data CSV
output_name<- paste(basename_file_data,"_cleaned.csv", sep="")
data<-read.csv(name_file_data, header = TRUE)
#standardize column name
cols <- c('x_utm', 'y_utm', 'CV_1', 'CV_05', 'IV_1', 'IV_05') #without elev
#cols <- c('x_utm', 'y_utm','elev', 'CV_1', 'CV_05', 'IV_1', 'IV_05') #with elev
#cols <- c('x_utm', 'y_utm','CV_1', 'CV_05') #without elev IV nor elev
colnames(data) <- cols
#get statistics for all data
data_stats<-stat.desc(data,basic=TRUE, desc=TRUE, norm=FALSE, p=0.95)
# Values it returns:
#1 nbr.val (the count of values)      
#2 nbr.null (the count of null values)     
#3 nbr.na  (the count of missing values)     
#4 min          
#5 max          
#6 range        
#7 sum          
#8 median       
#9 mean         
#10 SE.mean      
#11 CI.mean      
#12 var          
#13 std.dev      
# coef.var     
# skewness     ##need to enable norm = TRUE
# skew.2SE     
# kurtosis     
# kurt.2SE     
# normtest.W   
# normtest.p  

### clean CV_1m ###
cv1m_mean<-data_stats$CV_1[9] #Get the mean for the CV at 1m
cv1m_min<-data_stats$CV_1[4] #Get the min for the CV at 1m
cv1m_max<-data_stats$CV_1[5] #Get the max for the CV at 1m
cv1m_std<-data_stats$CV_1[13] #Get the std.dev for the CV at 1m
#Normalize formula:reading - mean / std
for (i in 1:length(data$CV_1)) {
  #Normalize CV_1m
  data$CV_1_norm[i] <- (data$CV_1[i]-cv1m_mean)/cv1m_std
}

### clean CV_05m ###
cv05m_mean<-data_stats$CV_05[9] #Get the mean for the CV at 1m
cv05m_min<-data_stats$CV_05[4] #Get the min for the CV at 1m
cv05m_max<-data_stats$CV_05[5] #Get the max for the CV at 1m
cv05m_std<-data_stats$CV_05[13] #Get the std.dev for the CV at 1m
#Normalize formula:reading - mean / std
for (i in 1:length(data$CV_05)) {
  #Normalize CV_05m
  data$CV_05_norm[i] <- (data$CV_05[i]-cv05m_mean)/cv05m_std
}

### clean IV_1m ###
iv1m_mean<-data_stats$IV_1[9] #Get the mean for the CV at 1m
iv1m_min<-data_stats$IV_1[4] #Get the min for the CV at 1m
iv1m_max<-data_stats$IV_1[5] #Get the max for the CV at 1m
iv1m_std<-data_stats$IV_1[13] #Get the std.dev for the CV at 1m
#Normalize formula:reading - mean / std
for (i in 1:length(data$IV_1)) {
  #Normalize CV_1m
  data$IV_1_norm[i] <- (data$IV_1[i]-iv1m_mean)/iv1m_std
}

### clean IV_05m ###
iv05m_mean<-data_stats$IV_05[9] #Get the mean for the CV at 1m
iv05m_min<-data_stats$IV_05[4] #Get the min for the CV at 1m
iv05m_max<-data_stats$IV_05[5] #Get the max for the CV at 1m
iv05m_std<-data_stats$IV_05[13] #Get the std.dev for the CV at 1m
#Normalize formula:reading - mean / std
for (i in 1:length(data$IV_05)) {
  #Normalize CV_05m
  data$IV_05_norm[i] <- (data$IV_05[i]-iv05m_mean)/iv05m_std
}

#keep values of 1m normalization beteen 3 and -3
data_cleaned1<-subset(data, data$CV_05_norm<=3 & data$CV_05_norm>=-3)
data_cleaned1<-subset(data, data$CV_1_norm<=3 & data$CV_1_norm>=-3)
data_cleaned1<-subset(data, data$IV_05_norm<=3 & data$IV_05_norm>=-3)
data_cleaned1<-subset(data, data$IV_1_norm<=3 & data$IV_1_norm>=-3)

### Graphics ###
#Graphics to save to PDF
pdf(file=paste("hist",basename_file_data,".pdf", sep=""))
par(mfrow=c(2,1))
#hist(data$CV_05_norm, main =paste("Histogram data$CV_05_norm"),xlab = "data$CV_05_norm", nclass = 20)
hist(data$CV_05, main =paste("Histogram data$CV_05"),xlab = "data$CV_05", nclass = 20)
hist(data$CV_1, main =paste("Histogram data$CV_1"),xlab = "data$CV_1", nclass = 20)
#hist(data$CV_1_norm, main =paste("Histogram data$CV_1_norm"),xlab = "data$CV_1_norm", nclass = 20)

#now the normalized ones
hist(data_cleaned1$CV_05, main =paste("Histogram data$CV_05"),xlab = "data_cleaned1$CV_05", nclass = 20)
hist(data_cleaned1$CV_1, main =paste("Histogram data$CV_1"),xlab = "data_cleaned1$CV_1", nclass = 20)
dev.off()
#Finish saving to PDF

##Write result to text file
data_cleaned1 <- subset(data_cleaned1, select=cols)
write.csv(data_cleaned1, file = output_name,row.names=FALSE)
