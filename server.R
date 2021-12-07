library(shiny)
library(leaflet)
library(tigris)
library(dplyr)
library(magrittr)
library(tidyverse)
library(readxl)
library(stringr)

server <- function(input, output) {
  states <- states(cb=T)

  select_options = c("income", "fast food")
  corr_options = c("per_100k, income, food insecurity")

  what.to.map <- reactive(input$map_var)
  
  # Food Insecurity Data
  state_data <- read_excel("./Map_the_Meal_Gap_Data/Map the Meal Gap Data/MMG2021_2019Data_ToShare.xlsx", sheet="2019 State")
  insecurity_rate <- state_data %>% select("State Name", "State", "2019 Food Insecurity Rate")
  colnames(insecurity_rate) <- c("state_name", "state", "rate")
  
  # Income Data
  income_data <- read_csv("./income_by_state.csv")
  states_merged_income <- geo_join(states, income_data, "NAME", "state")
  
  # Use the dropdown to decide which to visualize on the map
  output$map <- renderLeaflet({
    if(what.to.map() == "food"){
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

  
  
  # population.by.state <- as.data.frame(list(pop=(state_data["# of Food Insecure Persons in 2019"] / state_data["2019 Food Insecurity Rate"]), state.abb=state_data$`State`))
  # colnames(population.by.state) <- c("pop", "province")
  # 
  # # Plot fast food data
  # fast_food_res <- read_csv("FastFoodRestaurants.csv")
  # top_res <- fast_food_res %>% group_by(name) %>% count() %>% arrange(desc(n)) %>% select("name") %>% head(8)
  # fast_food_res_top <- fast_food_res %>% subset(name %in% unlist(top_res))
  # 
  # # num restaurants per capita
  # fast_food_per_state <- fast_food_res %>% group_by(province) %>% count()
  # ff_per_100k <- inner_join(fast_food_per_state, population.by.state, by="province") %>% mutate(per_100k = n / pop * 100000) %>% arrange(desc(per_100k))
  # 
  
  ff_per_100k <- read.csv("fast_food_per_100k.csv")
  
  #correlation between num of restaurants per 100000 and food insecurity rate
  corr_table <- inner_join(state_data, ff_per_100k %>% rename(State=province), by='State') %>%
    inner_join(income_data %>% rename(`State Name`=state), by="State Name") %>%
    select(State, per_100k, `2019 Food Insecurity Rate`, income)
      
  
  output$table <- renderDataTable(corr_table %>% mutate(per_100k=round(per_100k, 2)))
  

  corr.graph <- reactive(input$corr_graph)

  
  output$correlation_plot <- renderPlot({
    choices = c("per_100k x income", "income x food insecurity", "per_100k x food insecurity")

    if(corr.graph() == choices[1]){
      return(ggplot(data=corr_table, aes(x = per_100k, y = income)) + geom_point() +
               labs(x="per_100k", y="income") + theme_bw())
    } else if(corr.graph() == choices[2]){
      return(ggplot(data=corr_table, aes(x = income, y = `2019 Food Insecurity Rate`)) + geom_point() +
               labs(x = "income", y = "2019 Food Insecurity Rate") + theme_bw())
    } else{
      return(ggplot(data=corr_table, aes(x = per_100k, y = `2019 Food Insecurity Rate`)) + geom_point() +
               labs(x = "per_100k", y = "2019 Food Insecurity Rate") + theme_bw())
    }
  })
  
  
  output$corr <- renderText({
    choices = c("per_100k x income", "income x food insecurity", "per_100k x food insecurity")
    corr_num <- 0
    
    if(corr.graph() == choices[1]){
      corr_num <- round(cor(corr_table$`per_100k`, corr_table$income), 2)
    } else if(corr.graph() == choices[2]){
      corr_num <- round(cor(corr_table$`2019 Food Insecurity Rate`, corr_table$income), 2)
    } else{
      corr_num <- round(cor(corr_table$`2019 Food Insecurity Rate`, corr_table$per_100k), 2)
    }
    return(paste0("Correlation: ", toString(corr_num), sep=" "))
  })
  }