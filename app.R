#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(tigris)
library(dplyr)
library(tidyverse)
library(readxl)
library(stringr)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Food Insecurity Data"),


        # Show a plot of the generated distribution
        mainPanel(
            leaflet() %>%
                addProviderTiles("CartoDB.Positron") %>%
                setView(-98.483330, 38.712046, zoom = 4) %>% 
                addPolygons(data = counties_merged_insecurity , 
                            fillColor = ~pal1(counties_merged_insecurity$rate), 
                            fillOpacity = 0.7, 
                            weight = 0.2, 
                            smoothFactor = 0.2, 
                            popup = ~popup_sb_1)
            

        )
    
)

server <- function(input, output) {
    # states <- states(cb=T)
    # state_data <- read_excel("./Map_the_Meal_Gap_Data/Map the Meal Gap Data/MMG2021_2019Data_ToShare.xlsx", sheet="2019 State")
    # insecurity_rate <- state_data %>% select("State Name", "State", "2019 Food Insecurity Rate")
    # colnames(insecurity_rate) <- c("state_name", "state", "rate")
    # states_merged_insecurity <- geo_join(states, insecurity_rate, "STUSPS", "state")
    # pal <- colorNumeric("Greens", domain=states_merged_insecurity$rate)
    # popup_sb <- paste0("Total: ", as.character(states_merged_insecurity$rate))

    
    # Process counties shapefile
    
    counties <- counties(cb=T)
    
    # change all STATEFP to state names
    state_fp_names = vector()
    for(fp in unique(counties$STATEFP)) {
        state_fp_names = append(state_fp_names, str_split(lookup_code(fp), " ")[[1]][4])
    }
    
    fp_dict = as.data.frame(list("STATEFP"=unique(counties$STATEFP), "state"=state_fp_names ))
    
    counties_new <- geo_join(counties, fp_dict, by="STATEFP")
    counties_new$combined_name <- paste(counties_new$NAME %>% tolower(), counties_new$state %>% tolower(), " ")
    # Process county data from Feeding America
    county_data <- read_excel("./Map_the_Meal_Gap_Data/Map the Meal Gap Data/MMG2021_2019Data_ToShare.xlsx", sheet="2019 County")

    county_data <- county_data %>% separate("County, State", into=c("county", "state"), sep=", ")
        
    pattern = "county|city and borough|city|borough|municipality|census area"
    county_data$county <- gsub(pattern, "", county_data$county %>% tolower()) %>% str_trim()
    county_data$combined_name <- paste(county_data$county, county_data$state %>% tolower(), " ")
    
    # Merge shapefile with data to plot map
    county_insecurity_rate <- county_data %>% select("county", "state", "combined_name", "2019 Food Insecurity Rate")
    colnames(county_insecurity_rate) <- c("county", "state", "combined_name", "rate")
    
    counties_merged_insecurity <- geo_join(counties_new, county_insecurity_rate, by="combined_name") # check this op to make sure counties are merged right, esp if they have same names
    pal1 <- colorNumeric("Greens", domain=counties_merged_insecurity$rate)
    popup_sb_1 <- paste0("Total: ", as.character(counties_merged_insecurity$rate))
    
    # counties_new <- filter_at("NAME" == "Aleutians")
    # which(counties_new$NAME == "Assumption Parish", arr.ind=TRUE)
    # class(counties_new)
}
    
# Run the application 
shinyApp(ui = ui, server = server)
