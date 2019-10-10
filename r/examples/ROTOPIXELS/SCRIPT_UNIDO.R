#Arrange tables from zonalStatistics Extraction
#Take all the tables from a in different DBF files of zonal statistics and put in one same table all the rowsdate-cam and put in one Excel table
#Input should be dbf files 

# Used Packages
library(foreign)
#library(xlsx)
library(stringr)
library(plyr)
#library(gtools)
library(reshape2)
library(corrplot)
library(psych)
library(ggplot2)
library(car)
library(Hmisc)

### FUNCTIONS
#Input should be dbf files 

#######################################################

readTables <- function (f){
  ##read dbFfile
  t <- read.dbf(f)
  
  ##know name of the file without extention
  f_noExt <- gsub(".dbf","",f)
  #Separate the Field name, date and VI from the table name
  metadata <- unlist(strsplit(f_noExt, "_"))
  ##Add the data to new columns
  t$id <- paste0(metadata[1],"_",metadata[2]) #Field 
  t$field <- metadata[1] #Field 
  t$date <- metadata[2] #Date 
  t$VI <- gsub('B1','',metadata[3]) #VI 
  return (t)
}


#read tables
#################   Check these inputs#########################
#wd<-("C:\\Users\\CIMMYT\\Documents\\ArcGIS")
wd <- "E:\\rotopixels2018\\1_INDICES\\0_estadisticas"
setwd(wd)
getwd()

## Rread extra data that will be merged to the VI data, needs to have the "id" field or will fail the script
##read metadatos
m <- read.csv("metadatos_rotopixels.csv")
##read n content, needs to have the "boleta" field
n <- read.csv("DATOS_DEL_LABORATORIO.csv",stringsAsFactors=FALSE)
n[is.na(n)] <- NA #remove no data(.)
n <-n[ ! n$N_PERCENT %in% '.', ]
n$N_PERCENT<-as.numeric(n$N_PERCENT) 
#Get all the names of the DBFs to read
allDbfFiles <-list.files(pattern="\\.dbf$")

## Put together all the rows of the different tables with the custom function "readTables" into a list
#Read all the files to a list
tables.list = lapply(allDbfFiles,readTables)
#Merge with row bind tool into one table
table_ <- Reduce(rbind, tables.list)
#Merge VIs table with metadata
table_m <-merge(table_,m,by="id")
#Merge VIs table with the Nitrogen content data
table <-merge(table_m,n,by="boleta")
#dividir los indices entre dias de siembra y dia a la toma
table$MEAN_NORM_DIAS <- table$MEAN/table$dias_siembra_a_imagen 
#Edicion de boletas de JASP para que no se combinen con las de Lupita14
table$boleta[table$Campos=='jasp']<-paste0('0',table$boleta[table$Campos=='jasp'])


##Separate in columns the VIs for each date -- Wide table
#Change back from long to wide table
# a "formula object" is used in the  form: varDependent ~ varIndependent
wtable <- dcast(table, boleta+Campos+WG+DG+W400+HT+PB+PN+N_PERCENT+rich_strip ~ 
                  VI+num_medicion, value.var='MEAN')

#tabla temporal para anadir atributos por fecha en columnas
#Days from sowing to image capture
t_dias <- dcast(table, boleta ~ num_medicion, value.var='dias_siembra_a_imagen',fun=mean)
t_dias[is.na(t_dias)] <- NA #and remove NaNs
colnames(t_dias)[2:4] <- paste0("dias_siembra_a_img",colnames(t_dias)[2:4])

#ISSUES in images
t_issues <-dcast(table, boleta ~ num_medicion, value.var='ISSUES',fun=mean) 
t_issues[is.na(t_issues)] <- NA #and remove NaNs
colnames(t_issues)[2:4] <- paste0("ISSUES_img",colnames(t_issues)[2:4])

#Fecha de toma de imagen
table$date <- as.numeric(table$date) #Use the date as numeric to be able to summarize it
t_date_img <-dcast(table, boleta ~ num_medicion, value.var='date',fun=mean)
t_date_img[is.na(t_date_img)] <- NA #and remove NaNs
colnames(t_date_img)[2:4] <- paste0("date_img",colnames(t_date_img)[2:4])

#Join to wtable
table_complete <-merge(wtable,t_dias,by="boleta") #Add dias_siembra_a_imagen
table_complete <-merge(table_complete,t_issues,by="boleta") # Add issues column
table_complete <-merge(table_complete,t_date_img,by="boleta") # Add capture date

##Save table
#write.csv(table,"Tabla.csv", row.names=FALSE) #Tabla que usamos. Long table. 
#write.csv(table_complete,"Tabla_VIs_by_column_by_date.csv", row.names=FALSE)

##################################################################
#######################Termina creacion de las tablas############
##################################################################

source("C:/Users/Cynthia/Dropbox (RSG)/Software/Scripts/r/ROTOPIXELS/graficas_rotopixels.R")
#Graficar VIs vs proteina
#graficar_VI_cada_fecha_norm() #normalizado
#graficar_VI_cada_fecha()
##graficar_VI_todas_fechas_por_campo_norm()


###########################################################################################
######## HEATMAP ##########################################################################

table_complete$rich_strip=NULL
mydata <- (table_complete[c(9,10:15)])
head(mydata)
cormat <- round(cor(mydata,use="pairwise.complete.obs")^ 2,2)
head(cormat)
melted_cormat <- melt(cormat)
head(melted_cormat)  
ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}
upper_tri <- get_upper_tri(cormat)
upper_tri
melted_cormat <- melt(upper_tri, na.rm = TRUE)

ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Coeficiente\nDeterminacion") +
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()
# Print the heatmap
print(ggheatmap)
ggheatmap + 
  geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal")+
  guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
                               title.position = "top", title.hjust = 0.5))

##############################################################################################
##############################################################################################

francelino <- read.csv("E:\\rotopixels2018\\1_INDICES\\Tabla_VIs_by_column_by_date_con_indices_francelino.csv")

francelino$rich_strip=NULL
mydatafran <- (francelino[c(9,49:60)])
head(mydatafran)
cormat <- round(cor(mydatafran,use="pairwise.complete.obs")^ 2,2)
head(cormat)
melted_cormat <- melt(cormat)
head(melted_cormat)  
ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}
upper_tri <- get_upper_tri(cormat)
upper_tri
melted_cormat <- melt(upper_tri, na.rm = TRUE)

ggheatmapfran <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Coeficiente\nDeterminacion") +
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()
# Print the heatmap
print(ggheatmapfran)
ggheatmapfran + 
  geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal")+
  guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
                               title.position = "top", title.hjust = 0.5))

#####################################################################################
#####################################################################################





























#http://rstudio-pubs-static.s3.amazonaws.com/386125_78d0d3c7dfae4d0e9346df61495e164a.html
#https://www.youtube.com/watch?v=lkA_bauTB_s
#https://rpubs.com/ronnyhdez/260186

#http://www.sthda.com/english/wiki/ggplot2-quick-correlation-matrix-heatmap-r-software-and-data-visualization

#Ejemplo para filtrar
table[table$num_medicion==2,]
table[table$VI=="NDVI" & table$num_medicion==2,] #filas,columnas
table[table$VI=="R675" | table$VI=="NDVI",]



columna_nro <- 8
fila_nro <-3
print(table[fila_nro,columna_nro])
print(table[1:5,1:3]) #escoger un rango de filas y columnas 
sum(table[,"MEAN"]) #antes de la coma se indexan filas y despues columnas
unique(table$VI) #obtener valores unicos
sum(table[,15]=="3") #sumar cuantas veces se repite un dato
print(table[3,]) 

######################################################################
atributo <- "MEAN"                                                   #
target <- "VI"      #Para filtrar tabla(mean,VI,fecha)#              #
label <- "GM1"                                                       #
fechasiem <- "num_medicion"                                          #
table[(table[,target]==label) & (table[,fechasiem]=="3"),]           #
fomfil <- table[(table[,target]==label) & (table[,fechasiem]=="3"),] #
#
cor(fomfil$MEAN, fomfil$N_PERCENT)                                   #
######################################################################

# Para eliminar columnas
mydata$MEAN_NORM_DIAS=NULL
mydata$ISSUES=NULL
mydata$boleta=NULL
mydata$date=NULL
mydata$KB=NULL
mydata$MIN=NULL
mydata$PN=NULL
mydata$rich_strip=NULL
mydata$PB=NULL
mydata$HT=NULL


##21/05/2019##

library("car")
library("Hmisc")

head(Soils)
str(Soils)
cor(Soils[,6:14])


table_complete$rich_strip=NULL

round(cor(table_complete[,9:18],use="pairwise.complete.obs") ^ 2,4)




mi_correla <- melt(round(cor(table_complete[,9:75],use="pairwise.complete.obs") ^ 2,4))
head(mi_correla)

ggplot(data = mi_correla, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Coeficiente\nDeterminacion") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()




pairs(~table_complete$`790550_1`+table_complete$`790550_2`+table_complete$`790550_3`+table_complete$CCCI_1+table_complete$CCCI_2+table_complete$CCCI_3+table_complete$GM1_2+table_complete$GM1_3,cex.labels=1.2)

round(cor(~table_complete$GM1_3,use="pairwise.complete.obs") ^ 2,4)

#prueba de correlacion que te da intervalo de confianza, hipoteisis
cor.test(table_complete[,9],table_complete[,14])



#######################################################################
##########ELIMINADO DEL SCRIPT FIJO POR REPETICION#####################

# Heatmap
ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()

#######################################################################
#######################################################################








