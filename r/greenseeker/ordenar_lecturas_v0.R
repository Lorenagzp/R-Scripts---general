#Format the Greenseeker readings done in the experimental station to match the plot number ID
#Because they have an automatic incremental id
library(tools) #to use file_path_sans_ext


###############Functions
source(file.path("C:","Dropbox","Software","Scripts","r","greenseeker","methods_greenseeker.R", fsep = .Platform$file.sep))


################ INPUTS
#Set the WD
setwd(choose.dir(default = file.path("C:","Dropbox","data","AF", fsep = .Platform$file.sep), caption = "Select folder to work on"))

#Choose NDVIfile 
#The txt file is expected to have a standard name as: eg. AF_521_080318.txt ~ the date in ddmmyy format
ndviF <-   choose.files(default = "", caption = "Selecciona el archivo a procesar",
                               multi = FALSE, filters = matrix(c("txt", "*txt")),
                               index = nrow(Filters))
filename <- tools::file_path_sans_ext(basename(ndviF))

#Choose Trial map in csv format, north is up.
mapF <-   choose.files(default = "", caption = "Selecciona el archivo mapa del experimento",
                               multi = FALSE, filters = matrix(c("csv", "*csv")),
                               index = nrow(Filters))

#Choose measuring order 
#### interactively
ordF <-   choose.files(default = "", caption = "Selecciona el archivo que indica el orden de las lecturas (# filas y columnas = al mapa)",
                       multi = FALSE, filters = matrix(c("csv", "*csv")),
                       index = nrow(Filters))
#### OR Use this to get the order file automatically based on the date in ddmmyy in the NDVI txt file
#ord_Folder_location <- file.path("C:","Dropbox","data","AF","nut","csv_maps", fsep = .Platform$file.sep) #Location of all the ord files
#ordF <- get_ordFile(ndviF,ord_Folder_location)
#### OR hardcoded...
#ordF <- file.path(ord_Folder_location,"q21__af__ord_se.csv", fsep = .Platform$file.sep)

#"extra" Readings we dont need
no_go <- c("") #HardCoded !!!!!!!!!!!! eg. c("5","46")


############### SCRIPT
tryCatch({
  
  dataNDVI<-read.table(ndviF, header = TRUE,sep = ",") #get the data in the csv File
  #Clean extra readings from the NDVI file, that are by mistake. Indicated in the "no_go" variable. Cleaning the order file should be done separately, its not done here.
  ndviCl <- dataNDVI[which(!(dataNDVI$Plot %in% no_go)),]
  #Replace the "Plot" header by "Sample_No", because in the NDVI file
  colnames(ndviCl)[colnames(ndviCl) == "Plot"] <- "Sample_No"
  #Average the readings, get SD, and CV. Group by "Sample_no"
  ndviAvg <-averageNDVI(ndviCl)
  map<-read.table(mapF, header = FALSE,sep = ",") #get the data in the csv "map"
  ord<-read.table(ordF, header = FALSE,sep = ",") #get the sampling order from file
  #print(ord)
  orddata <- s_order(map,ord,ndviAvg) #match the readings and the plot names
  write.csv(orddata,paste0(filename,"_ndvi.csv"), row.names=FALSE) #write the data in a text file
})
