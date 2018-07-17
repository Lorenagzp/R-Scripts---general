library(shiny)


shinyUI(fluidPage(
  titlePanel("Calculate plant height"),
  sidebarLayout(
    sidebarPanel(
      h3("Involved images"),
      
      fluidRow(
        column(3, 
               h3("Help text"),
               helpText("Tests: ")),
        column(3,
               fileInput("file", label = h3("File input"))),
        column(3, 
               numericInput("num", 
                            label = h3("Numeric input"), 
                            value = 1))
        
      ),
      
      fluidRow(
        helpText("Create demographic maps with 
        information from the 2010 US Census."),
        
        selectInput("var", 
                    label = "Choose a variable to display",
                    choices = c("Percent White", "Percent Black",
                                "Percent Hispanic", "Percent Asian"),
                    selected = "Percent White"),
        
        sliderInput("range", 
                    label = "Range of interest:",
                    min = 0, max = 100, value = c(0, 100))
      )
      
    ),
    mainPanel(
      textOutput("text1"),
      textOutput("text2"),
      #plotOutput(),
      #tableOutput(),
      
      p("Got to the CIMMYT ",
        a("web page", 
          href = "http://www.cimmyt.org/es/")),
      img(src="circles in a circle Kandinsky.jpg", height = 400, width = 400),
      
      plotOutput("map")
    )
  )
))