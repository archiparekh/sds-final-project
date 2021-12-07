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
      
    ),
    
    mainPanel(
      
      leafletOutput('map'),
      textOutput('corr'),
      dataTableOutput('table')
      
    )
  )
)



