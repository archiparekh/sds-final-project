library(shiny)
library(magrittr)
library(dplyr)
library(leaflet)


ui <- fluidPage(
  
  titlePanel(title = "Food Insecurity and Income and Fast Food"),
  
    mainPanel(
      radioButtons("map_var", "Map by",
                   choiceNames = list(
                     "Food Insecurity Rate", "Median Income"
                   ),
                   choiceValues = list(
                     "Food Insecurity Rate", "Median Income"
                   )),
      leafletOutput('map'),
      hr(), 
      selectInput(inputId = "corr_graph", 
                  label = "Select correlation vars:", 
                  choices = c("Restaurants (Per 100k) x Median Income",
                              "Median Income x Food Insecurity Rate",
                              "Restaurants (Per 100k) x Food Insecurity Rate")),
      plotOutput("correlation_plot"),
      textOutput('corr'),
      hr(), 
      dataTableOutput('table')
    )
  )




