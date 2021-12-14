library(shiny)
library(magrittr)
library(dplyr)
library(leaflet)


ui <- fluidPage(
  
  titlePanel(title = "Food Insecurity, Income, and the Frequency of Fast Food Restaurants in 2019"),
  p("Food insecurity is the lack of healthy, consistent food sources. It can be correlated with many life factors, such as income, race, and education. Here, we will explore the connections between food insecurity and income, and whether the frequency of fast food restaurants is correlated with food insecurity. "), 
    mainPanel(
      hr(), 
      radioButtons("map_var", "Map by",
                   choiceNames = list(
                     "Food Insecurity Rate", "Median Income"
                   ),
                   choiceValues = list(
                     "Food Insecurity Rate", "Median Income"
                   )),
      h3(textOutput("map_title")),
      leafletOutput('map'),
      hr(), 
      selectInput(inputId = "corr_graph", 
                  label = "Select correlation vars:", 
                  choices = c("Restaurants (Per 100k) x Median Income",
                              "Median Income x Food Insecurity Rate",
                              "Restaurants (Per 100k) x Food Insecurity Rate")),
      h3(textOutput("plot_title")),
      plotOutput("correlation_plot"),
      textOutput('corr'),
      hr(), 
      h3("Explore the Data"),
      dataTableOutput('table')
    )
  )




