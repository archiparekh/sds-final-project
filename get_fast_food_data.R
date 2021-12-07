library(tidyverse)
library(stringr)
library(dplyr)
library(rvest)

state_data <- read_excel("./Map_the_Meal_Gap_Data/Map the Meal Gap Data/MMG2021_2019Data_ToShare.xlsx", sheet="2019 State")

population.by.state <- as.data.frame(list(pop=(state_data["# of Food Insecure Persons in 2019"] / state_data["2019 Food Insecurity Rate"]), state.abb=state_data$`State`))
colnames(population.by.state) <- c("pop", "province")

fast_food_res <- read_csv("FastFoodRestaurants.csv")
top_res <- fast_food_res %>% group_by(name) %>% count() %>% arrange(desc(n)) %>% select("name") %>% head(8)
fast_food_res_top <- fast_food_res %>% subset(name %in% unlist(top_res))

# num restaurants per capita
fast_food_per_state <- fast_food_res %>% group_by(province) %>% count()
ff_per_100k <- inner_join(fast_food_per_state, population.by.state, by="province") %>% mutate(per_100k = n / pop * 100000) %>% arrange(desc(per_100k))

write.csv(ff_per_100k, "fast_food_per_100k.csv")
