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
  state_data <- read_excel("./Map_the_Meal_Gap_Data/Map the Meal Gap Data/MMG2021_2019Data_ToShare.xlsx", sheet="2019 State")
  insecurity_rate <- state_data %>% select("State Name", "State", "2019 Food Insecurity Rate")
  colnames(insecurity_rate) <- c("state_name", "state", "rate")
  states_merged_insecurity <- geo_join(states, insecurity_rate, "STUSPS", "state")
  pal <- colorNumeric("Greens", domain=states_merged_insecurity$rate)
  popup_sb <- paste0("Rate: ", as.character(states_merged_insecurity$rate))
  
  
  # Process counties shapefile
  
  # counties <- counties(cb=T)
  # 
  # # change all STATEFP to state names
  # state_fp_names = vector()
  # for(fp in unique(counties$STATEFP)) {
  #     state_fp_names = append(state_fp_names, str_split(lookup_code(fp), " ")[[1]][4])
  # }
  # 
  # fp_dict = as.data.frame(list("STATEFP"=unique(counties$STATEFP), "state"=state_fp_names ))
  # 
  # counties_new <- geo_join(counties, fp_dict, by="STATEFP")
  # counties_new$combined_name <- paste(counties_new$NAME %>% tolower(), counties_new$state %>% tolower(), " ")
  # # Process county data from Feeding America
  # county_data <- read_excel("./Map_the_Meal_Gap_Data/Map the Meal Gap Data/MMG2021_2019Data_ToShare.xlsx", sheet="2019 County")
  # 
  # county_data <- county_data %>% separate("County, State", into=c("county", "state"), sep=", ")
  #     
  # pattern = "county|city and borough|city|borough|municipality|census area"
  # county_data$county <- gsub(pattern, "", county_data$county %>% tolower()) %>% str_trim()
  # county_data$combined_name <- paste(county_data$county, county_data$state %>% tolower(), " ")
  # 
  # # Merge shapefile with data to plot map
  # county_insecurity_rate <- county_data %>% select("county", "state", "combined_name", "2019 Food Insecurity Rate")
  # colnames(county_insecurity_rate) <- c("county", "state", "combined_name", "rate")
  # 
  # counties_merged_insecurity <- geo_join(counties_new, county_insecurity_rate, by="combined_name") # check this op to make sure counties are merged right, esp if they have same names
  # pal1 <- colorNumeric("Greens", domain=counties_merged_insecurity$rate)
  # popup_sb_1 <- paste0("Total: ", as.character(counties_merged_insecurity$rate))
  
  population.by.state <- as.data.frame(list(pop=(state_data["# of Food Insecure Persons in 2019"] / state_data["2019 Food Insecurity Rate"]), state.abb=state_data$`State`))
  colnames(population.by.state) <- c("pop", "province")
  
  # Plot fast food data
  fast_food_res <- read_csv("FastFoodRestaurants.csv")
  top_res <- fast_food_res %>% group_by(name) %>% count() %>% arrange(desc(n)) %>% select("name") %>% head(8)
  fast_food_res_top <- fast_food_res %>% subset(name %in% unlist(top_res))
  
  # num restaurants per capita
  fast_food_per_state <- fast_food_res %>% group_by(province) %>% count()
  ff_per_100k <- inner_join(fast_food_per_state, population.by.state, by="province") %>% mutate(per_100k = n / pop * 100000) %>% arrange(desc(per_100k))
  
  
  #correlation between num of restaurants per 100000 and food insecurity rate
  corr_table <- inner_join(state_data, ff_per_100k %>% rename(State=province), by='State') %>% select(State, per_100k, `2019 Food Insecurity Rate`)
  output$table <- renderDataTable(corr_table %>% mutate(per_100k=round(per_100k, 2)))
  
  corr_num <- round(cor(corr_table$`2019 Food Insecurity Rate`, corr_table$per_100k), 2)
  
  output$map <- renderLeaflet(leaflet() %>%
    addProviderTiles("CartoDB.Positron") %>%
    setView(-98.483330, 38.712046, zoom = 4) %>%
    addPolygons(data = states_merged_insecurity ,
                fillColor = ~pal(states_merged_insecurity$rate),
                fillOpacity = 0.7,
                weight = 0.2,
                smoothFactor = 0.2,
                popup = ~popup_sb)  %>% 
    addLegend(pal = pal, values = states_merged_insecurity$rate, opacity = 1))
  
  
  output$corr <- renderText(paste0("Correlation between number of fast food restaurant per 100k and Food Insecurity: ", toString(corr_num), sep=" "))
}