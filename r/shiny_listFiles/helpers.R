saveData <- function(data) {
  #data <- t(data)

  #test to save to file
  write.csv(data, file="C://Dropbox//data//shiny_output_test.csv")
}

#Load data function...
loadDBData <- function() {
  # create a connection to  a DB in postres
  # save the password that we can "hide" it as best as we can by collapsing it
  pw <- {
    "cimmyt"
  }
  
  # loads the PostgreSQL driver
  drv <- dbDriver("PostgreSQL")
  # creates a connection to the postgres database
  # note that "con" will be used later in each connection to the database
  # here the connection values should be specified
  connection <- dbConnect(drv, dbname = "ceneb_nut",
                          host = "localhost", port = 5432,
                          user = "postgres", password = pw)
  rm(pw) # removes the password
  
  # fetch the data from postgreSQL #capture" table
  df_log <- dbGetQuery(connection, "SELECT * from capture") #Returns a dataframe type
  
  # close the connection when finished
  dbDisconnect(connection)
  dbUnloadDriver(drv)
  ##>>>>>>>>>>>>>#  } connection to DB losed
  
  df_log
}