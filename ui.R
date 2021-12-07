library(shiny)
library(magrittr)
library(dplyr)
library(leaflet)


ui <- fluidPage(
  
  titlePanel(title = "Food Insecurity and Income and Fast Food"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      selectInput(inputId = "map_var", 
                  label = "Select X:", 
                  choices = c("income", "food")),
      
      selectInput(inputId = "corr_graph", 
                  label = "Select correlation vars:", 
                  choices = c("per_100k x income", "income x food insecurity", "per_100k x food insecurity")),
      
    ),
    
    mainPanel(
      
      leafletOutput('map'),
      plotOutput("correlation_plot"),
    
      textOutput('corr'),
      dataTableOutput('table')
      
    )
  )
)



