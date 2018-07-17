library(shiny)
library(maps)
library(mapproj)
source("helpers.R")
counties <- readRDS("data/counties.rds")

shinyServer(function(input, output) {
  
    output$text1 <- renderText({ 
      paste("You have selected", input$select)
    })
    
    output$text2 <- renderText({ 
      paste("You have selected", input$slider2[1],"and", input$slider2[2])
    })
    
    output$map <- renderPlot({
      args <- switch(input$var,
                     "Percent White" = list(counties$white, "darkgreen", "% White"),
                     "Percent Black" = list(counties$black, "black", "% Black"),
                     "Percent Hispanic" = list(counties$hispanic, "darkorange", "% Hispanic"),
                     "Percent Asian" = list(counties$asian, "darkviolet", "% Asian"))
      
      args$min <- input$range[1]
      args$max <- input$range[2]
      
      do.call(percent_map, args)
    })
      
  }
)