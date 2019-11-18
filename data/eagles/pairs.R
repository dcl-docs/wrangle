# Eagle pairs data from US Fish and Wildlife

# Author: Sara Altman
# Version: 2019-11-14

# Libraries
library(tidyverse)
library(rvest)

# Parameters
url_data <- "https://www.fws.gov/midwest/eagle/NestingData/nos_state_tbl.html"
css_selector <- "#rightCol > table > tr:nth-child(2) > td > table"
file_out <- here::here("data/eagles/eagle_pairs.rds")
years <- vars(`1997`:`2006`)
#===============================================================================
state_abbreviations <-
  state.abb %>% 
  discard(~ . %in% c("AK", "HI"))

v <-
  url_data %>% 
  read_html() %>% 
  html_node(css = css_selector) %>% 
  html_table() %>% 
  as_tibble() %>% 
  janitor::row_to_names(row_number = 1) %>% 
  rename(state = nn) %>% 
  filter(state != "") %>%
  arrange(state) %>% 
  mutate(state_abb = state_abbreviations) %>% 
  mutate_at(
    vars(-starts_with("state")), 
    ~ na_if(., "") %>%
      str_replace(pattern = '(".*")|(b.*)', replacement = NA_character_) %>% 
      as.integer()
  ) %>% 
  select(state, state_abb, !!!years) %>% 
  write_rds(file_out)
