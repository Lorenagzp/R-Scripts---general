#This procedure loads the log DB of the flights
#thanks https://ipub.com/shiny-crud-app/
# https://rstudio.github.io/DT/options.html
# Thanks to https://shiny.rstudio.com/articles/persistent-data-storage.html
#thanks to R documentation
#Edited: Lorena

library (raster)
library (sp)
library(rgdal)
require("RPostgreSQL")
library(rgdal)
source("helpers.R")

shinyServer(function(input, output,session) {
    
     #############Get the data from the DB
    df_log <- loadDBData()
     
     #Get the available unique data from the log table
     sensors <- unique(df_log$sensor) #sensors
     #date <- unique(df_log$cap_date) #dates
     trials <- unique(df_log$area) #trials
     
     
     #get the sensors as the options of a check box
     output$choose_cam <- renderUI({
       # If missing input, return to avoid error later in function
       #if(is.null(sensors))
       # return()
       
       # Create the checkboxes and select them all by default
       checkboxGroupInput("chk_cam", "Choose sensors", 
                          choices  = sensors,
                          selected = NULL)
     })
     
     #get the available trials as the options of a check box
     output$choose_trial <- renderUI({
       # If missing input, return to avoid error later in function
       #if(is.null(sensors))
       # return()
       
       # Create the checkboxes and select them all by default
       checkboxGroupInput("chk_trial", "Choose trial", 
                          choices  = trials,
                          selected = NULL)
     })
     
     
     #Render the table to display in the GUI
     output$logTable <- DT::renderDataTable({
       
       #update after submit is clicked
       input$submit
       #Filter the data as needed
       df_log <- df_log[df_log$area %in% c(input$chk_trial) & df_log$sensor %in% c(input$chk_cam), ]
       #save to csv the data
       #saveData(df_log) # This works!
       
       #The data retrieved from the DB, filtered
       df_log #This will be showed in the table UI
       
       
     },options = list(pageLength  = 15)) #show 15 rows by default
     
     #React when a row is selected
     # (Not working yet) # ! #
     # observeEvent(input$logTable_rows_selected, {
     #   output$txtOut <- renderText({ 
     #     data <- loadData()[input$logTable_rows_selected,] ### loadData() function????
     #     sprintf("You have selected: %s",data)}) #!# this doesnt work, how get the value selected I just get the index within the filtered table
      # })
  }
)