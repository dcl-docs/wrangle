# Description

# Author: Sara Altman
# Version: 2019-11-14

# Libraries
library(tidyverse)
library(tidycensus)

# Parameters
variables <- 
  c(
    "pop_housed" = "B25008_001", 
    "pop_renter" = "B25008_003",
    "median_rent" = "B25064_001"
  )
file_out <- here::here("data/acs/acs_2012_2017.rds")
#===============================================================================

get_acs_vars <- function(variables, year) {
  get_acs(
    geography = "state", 
    variables = variables, 
    year = year
  )
}

v <- 
  get_acs_vars(variables, 2012) %>% 
  bind_rows("2012" = ., "2017" = get_acs_vars(variables, 2017), .id = "year") %>% 
  select(GEOID, NAME, year, variable, estimate) %>% 
  rename_all(str_to_lower) %>% 
  write_rds(file_out)
