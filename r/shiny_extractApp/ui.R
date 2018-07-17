#show the table of the flights info

# thanks to https://shiny.rstudio.com/articles/datatables.html
# thanks to https://gist.github.com/wch/4211337


library("shiny")
library(DT)


shinyUI(fluidPage(
  titlePanel("Log control"),
  
  #For the inputs
  sidebarLayout(
    sidebarPanel(
      h3("Select options"),
      uiOutput("choose_cam"), #check options cam populated by the input table
      uiOutput("choose_trial") #check options trial populated by the input table
      
    ),
    
    #For the outputs
    mainPanel(
      h3("Log"),
      DT::dataTableOutput("logTable"),
      textOutput("txtOut") #here I want to show the selected row
      
    )
  )
))