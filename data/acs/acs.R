# Description

# Author: Sara Altman
# Version: 2019-11-14

# Libraries
library(tidyverse)
library(tidycensus)

# Parameters
YEAR <- 2016
variables <- 
  c(
    "pop_housed" = "B25008_001", 
    "pop_renter" = "B25008_003",
    "median_rent" = "B25064_001"
  )

states <- c("Alabama", "Georgia")

file_out_1 <- here::here("data/acs/acs_2016_1.rds")
file_out_2 <- here::here("data/acs/acs_2016_2.rds")
file_out_3 <- here::here("data/acs/acs_2016_3.rds")
file_out_4 <- here::here("data/acs/acs_2016_4.rds")
#===============================================================================

v <- 
  get_acs(
    geography = "state", 
    variables = variables, 
    year = YEAR
  ) %>% 
  rename_all(str_to_lower) %>% 
  rename(error = moe)

v %>% 
  select(geoid, name, variable, estimate) %>%
  write_rds(file_out_1)

v2 <-
  v %>% 
  filter(
    name %in% states,
    variable %in% c("pop_renter", "median_rent")
  ) %>% 
  write_rds(file_out_3)

v2 %>% 
  pivot_longer(
    cols = c(estimate, error), 
    names_to = "measure", 
    values_to = "value"
  ) %>% 
  write_rds(file_out_2)

v %>% 
  filter(name %in% states) %>% 
  write_rds(file_out_4)
  
