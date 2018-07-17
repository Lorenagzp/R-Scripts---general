# get Greenseekr measurements


library(plyr)





# ongoing













# #Working directory
wd=  choose.dir(default = "", caption = "Select working directory")
setwd(wd)
## What kind of files to seach
pattern="\\Avg.txt$"
#list all imagery in the folder
files <-list.files(pattern=pattern)

#Here we will save the summary of the readings
gs <- data.frame(Plot="0",
                   NDVI=0.5, 
                   stringsAsFactors=FALSE)
cols <- c("Plot", "NDVI")

for(f in files) {
  # read text
  d<-read.table(f, header = TRUE,sep = ",")
  #save just the coulumns I need
  d <- d[,c("Plot", "NDVI")]
  #Name the plot as the input filename
  d$Plot <- f
  gs <- rbind(gs,d)
  
}

#AVG
#avg_gs <- ddply(gs, .("Plot"), summarize,x = max(NDVI))

