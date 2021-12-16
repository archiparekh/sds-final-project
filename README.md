# Food Insecurity, Income, and the Frequency of Fast Food Restaurants in 2019

### Description
Food insecurity is the lack of healthy, consistent food sources. It can be correlated with many life factors, such as income, race, and education. Here, we will explore the connections between food insecurity and income, and whether the frequency of fast food restaurants is correlated with food insecurity. This dashboard is built using R Shiny. 

### Data Sources
To conduct this analysis, I gathered data from Feeding America, Kaggle, and National Center for Education Statistics. Feeding America's Map the Meal Gap program conducts surveys yearly to understand food insecurity in America. Their data is available on request online at https://www.feedingamerica.org/research/map-the-meal-gap/by-county?s_src=WXXX1MTMG&_ga=2.221711704.1980583324.1634933498-978913632.1634933498. 

A list of fast food restaurants in the US from Datainfiniti's business database was available online on Kaggle. This contains 10000 restaurants. https://www.kaggle.com/datafiniti/fast-food-restaurants

Median income data by state for 2019 was available on the NCES website. The data there was sourced from the US Census. I used webscraping to extract this data. https://nces.ed.gov/programs/digest/d20/tables/dt20_102.30.asp

### Findings of Interest
Food insecurity and fast food restaurant density are not correlated (0.17). After reading a few articles online, I found that middle class people are the highest consumers of fast food. This seems to explain why the correlation coefficient is so low. Food insecurity and income is strongly correlated (0.68). This is expected, given that lower income reduces access to good food options.

### Description of Files
To see the source code for the website, see **`app.R`**, **`server.R`**, **`ui.R`**. 
**`get_fast_food_data.R`** contains the script for aggregating restaurant data. 
**`income_by_state.R`** contains the script for scraping income data.

