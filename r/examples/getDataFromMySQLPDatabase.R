####
# GET  local DATABASE
####

#library(xlsx)
library(RMySQL)
library(XLConnect)

############################ FUNCTIONS DEFINITION


##Connecto to local Database
mydb = dbConnect(MySQL(), user='root', password='cimmyt', dbname='ac_stars', host='localhost')
tables <- dbListTables(mydb) #List tables on DB
t<- "esc151111ar1"
for (t in tables) {
  ##Make a query
  rs = dbSendQuery(mydb, paste("select * from",t))
  #fetch function to get the data
  data = fetch(rs, n=-1)
}

new <- merge(table,data, by = "id")

table$(paste(toString(t),"moisture")) <-data[,c("moisture")]
