# Description

# Author: Sara Altman
# Version: 2019-11-14

# Libraries
library(tidyverse)
library(tidycensus)

# Parameters
vars <- 
  c(
    "income" = "B06011_001", 
    "rent" = "B25064_001", 
    "n_poverty" = "B05010_001", 
    "n_renters" = "B25008_003"
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
# B25008_003 - renters for v17
# B25008_003
# Retrieve the data
v <- 
  get_acs_vars(vars, 2012) %>% 
  bind_rows("2012" = ., "2017" = get_acs_vars(vars, 2017), .id = "year") %>% 
  select(GEOID, NAME, year, variable, estimate) %>% 
  rename_all(str_to_lower) %>% 
  write_rds(file_out)
