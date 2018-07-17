setwd("C:/Dropbox/data/AE/nut/img")

files <- list.files(path = ".", full.names = FALSE, pattern = ".tif$",recursive = FALSE)
#file.path("folder","file") #function to concatenate folders to create a filepath
#write the final table
write.csv(files,paste("Files_img.csv", sep=""))
