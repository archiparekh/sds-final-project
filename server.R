library(shiny)
library(leaflet)
library(tigris)
library(dplyr)
library(magrittr)
library(tidyverse)
library(readxl)
library(stringr)

server <- function(input, output) {
  
  # Reactives
  what.to.map <- reactive(input$map_var)
  corr.graph <- reactive(input$corr_graph)
  
  # Dropdown Options
  map.options <- c("Food Insecurity Rate", "Median Income")
  corr.options <- c("Restaurants (Per 100k) x Median Income",
                    "Median Income x Food Insecurity Rate",
                    "Restaurants (Per 100k) x Food Insecurity Rate")
  
  # Data sources
  food_insecurity_data <- read_excel("./Map_the_Meal_Gap_Data/Map the Meal Gap Data/MMG2021_2019Data_ToShare.xlsx", sheet="2019 State")
  income_data <- read_csv("./income_by_state.csv")
  ff_per_100k <- read.csv("fast_food_per_100k.csv")
  states <- states(cb=T)

  # Datatable with all data points by state
  corr_table <- inner_join(food_insecurity_data, ff_per_100k %>% rename(State=province), by='State') %>%
    inner_join(income_data %>% rename(`State Name`=state), by="State Name") %>%
    select(State, per_100k, `2019 Food Insecurity Rate`, income)
  colnames(corr_table) <- c("State", "Restaurant Density", "Food Insecurity Rate", "Median Income")
  
  # Mapping food insecurity
  insecurity_rate <- food_insecurity_data %>% select("State Name", "State", "2019 Food Insecurity Rate")
  colnames(insecurity_rate) <- c("state_name", "state", "rate")
  
  # Mapping income
  states_merged_income <- geo_join(states, income_data, "NAME", "state")
  
  # Visualize on map
  output$map <- renderLeaflet({
    if(what.to.map() == map.options[1]){
      states_merged_insecurity <- geo_join(states, insecurity_rate, "STUSPS", "state")
      pal <- colorNumeric("Greens", domain=states_merged_insecurity$rate)
      popup_sb <- paste0("Rate: ", as.character(states_merged_insecurity$rate))
      
      return(leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        setView(-98.483330, 38.712046, zoom = 4) %>%
        addPolygons(data = states_merged_insecurity ,
                    fillColor = ~pal(states_merged_insecurity$rate),
                    fillOpacity = 0.7,
                    weight = 0.2,
                    smoothFactor = 0.2,
                    popup = ~popup_sb)  %>% 
        addLegend(pal = pal, values = states_merged_insecurity$rate, opacity = 1))
    } else {
      pal <- colorNumeric("Blues", domain=states_merged_income$income)
      popup_sb <- paste0("Income: ", as.character(states_merged_income$income))
      
      
      return(leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        setView(-98.483330, 38.712046, zoom = 4) %>%
        addPolygons(data = states_merged_income ,
                    fillColor = ~pal(states_merged_income$income),
                    fillOpacity = 0.7,
                    weight = 0.2,
                    smoothFactor = 0.2,
                    popup = ~popup_sb)  %>% 
        addLegend(pal = pal, values = states_merged_income$income, opacity = 1))
    }
  })

  # Correlation plot
  output$correlation_plot <- renderPlot({
    if(corr.graph() == corr.options[1]){
      return(ggplot(data=corr_table, aes(x = `Restaurant Density`, y = `Median Income`, color=State)) + geom_point() +
               labs(x="Restaurant Density", y="Median Income") + theme_bw())
    } else if(corr.graph() == corr.options[2]){
      return(ggplot(data=corr_table, aes(x = `Median Income`, y = `Food Insecurity Rate`, color=State)) + geom_point() +
               labs(x = "Median Income", y = "Food Insecurity Rate") + theme_bw())
    } else{
      return(ggplot(data=corr_table, aes(x = `Restaurant Density`, y = `Food Insecurity Rate`, color=State)) + geom_point() +
               labs(x = "Restaurant Density", y = "Food Insecurity Rate") + theme_bw())
    }
  })
  
  # Correlation coefficient
  output$corr <- renderText({
    corr_num <- 0
    
    if(corr.graph() == corr.options[1]){
      corr_num <- round(cor(corr_table$`Restaurant Density`, corr_table$`Median Income`), 2)
    } else if(corr.graph() == corr.options[2]){
      corr_num <- round(cor(corr_table$`Food Insecurity Rate`, corr_table$`Median Income`), 2)
    } else{
      corr_num <- round(cor(corr_table$`Food Insecurity Rate`, corr_table$`Restaurant Density`), 2)
    }
    return(paste0("Correlation: ", toString(corr_num), sep=" "))
  })
  
  
  
  output$table <- renderDataTable(corr_table %>% mutate(`Restaurant Density`=round(`Restaurant Density`, 2)))
  
}