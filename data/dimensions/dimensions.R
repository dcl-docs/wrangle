# Simulated dimensions data

# Author: Sara Altman
# Version: 2019-11-21

# Libraries
library(tidyverse)

# Parameters
file_out_1 <- here::here("data/dimensions/dimensions_1.rds")
file_out_2 <- here::here("data/dimensions/dimensions_2.rds")
file_out_3 <- here::here("data/dimensions/dimensions_3.rds")
#===============================================================================

dimensions <-
  tribble(
    ~item, ~estimate, ~measure, ~value, ~method,
    "marble", "median",   "volume", 1,  "displacement",
    "marble", "lower", "volume", 0.5,   "displacement",
    "marble", "upper", "volume", 1.5,   "displacement",
    "marble", "median",   "radius", 2,  NA_character_,
    "marble", "lower", "radius", 1.7,   NA_character_,
    "marble", "upper", "radius", 2.3,   NA_character_,
    "vase", "median",   "volume", 3,    "calculated",
    "vase", "lower", "volume", 2.4,     "calculated",
    "vase", "upper", "volume", 3.6,     "calculated",
    "vase", "median",   "radius", 5,    NA_character_,
    "vase", "lower", "radius", 4.2,     NA_character_,
    "vase", "upper", "radius", 5.8,     NA_character_
  ) 

dimensions <-
  tribble(
    ~item,    ~estimate, ~measure, ~value, ~method,
    "marble", "median",   "volume", 1,    "displacement",
    "marble", "se",       "volume", 0.1,  "displacement",
    "marble", "median",   "radius", 2,    NA_character_,
    "marble", "se",       "radius", 0.05, NA_character_,
    "vase",   "median",   "volume", 3,    "calculated",
    "vase",   "se",       "volume", 0.4,  "calculated",
    "vase",   "median",   "radius", 5,    NA_character_,
    "vase",   "se",       "radius", 0.2,  NA_character_
  ) 
  
dimensions %>% 
  select(item, measure, estimate, value) %>% 
  write_rds(file_out_1)

dimensions %>% 
  select(-method) %>% 
  pivot_wider(names_from = estimate, values_from = value) %>% 
  write_rds(file_out_2)

dimensions %>% 
  filter(estimate == "median") %>% 
  select(-estimate) %>% 
  write_rds(file_out_3)
