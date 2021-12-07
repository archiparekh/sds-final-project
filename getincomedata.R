# https://nces.ed.gov/programs/digest/d20/tables/dt20_102.30.asp

library(tidyverse)
library(stringr)
library(dplyr)
library(rvest)

# <td class="TblCls011">77,100</td>

income_table <- read_html("https://nces.ed.gov/programs/digest/d20/tables/dt20_102.30.asp")

t <- income_table %>% html_nodes("table.tabletop") %>% html_table()
class(t)
income_table <- t[[1]]
colnames(income_table) <- c(1:19)
income.by.state <- income_table %>% select(1, 18) %>% slice(-c(1:3))
colnames(income.by.state) <- c("state", "income")
income.by.state$income <- income.by.state$income %>% str_remove_all(",") %>% strtoi()
write.csv(income.by.state, "income_by_state.csv")
