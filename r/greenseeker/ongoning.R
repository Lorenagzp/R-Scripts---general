
### GREENSEEKSER(GS) ###
#This method will generate how the data will be ordered based on a matrix size and direction.
#way the sampling was done
#Skips the unwanted readings #: no_go
#Serpentine (serp): Indicate starting corner and it will be generated acordingly. It always runs in the North -south direction:
  #Possible values:
  #sw,se,no,ne
##################################################################################ONGOING
make_serpentine <- function(rows,cols,serp,no_go){
  #Number of total samples
  n <- 1:(rows*cols) + length(no_go)
  ord <- integer(0)
  #complete the order of the sampling
  for (cl in 1:cols){
    #cREATE the sequence based on the first and last readings in the bed
    ordColumn <- ordi[1,cl]:ordi[2,cl]
    print(ordColumn)
    #Remove numbers that correspond to the unwanted readings
    ordColumn[which(!(ordColumn %in% no_go))]
    ord <- cbind(ord,ordColumn) 
  }
  return(ord)
}