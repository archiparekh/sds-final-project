library(shiny)
library(magrittr)
library(dplyr)
library(leaflet)
ui <- fluidPage(
  
  # Application title
  titlePanel("Food Insecurity and Fast Food Restaurants"),
  
  
  # Show a plot of the generated distribution
  mainPanel(
    leafletOutput('map'),
    textOutput('corr'),
    dataTableOutput('table')
    # leaflet() %>%
    #     addProviderTiles("CartoDB.Positron") %>%
    #     setView(-98.483330, 38.712046, zoom = 4) %>% 
    #     addPolygons(data = counties_merged_insecurity , 
    #                 fillColor = ~pal1(counties_merged_insecurity$rate), 
    #                 fillOpacity = 0.7, 
    #                 weight = 0.2, 
    #                 smoothFactor = 0.2, 
    #                 popup = ~popup_sb_1)
    
    
  )
  
)