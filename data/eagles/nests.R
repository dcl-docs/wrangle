# Eagle nests data from US Fish and Wildlife

# Source: https://www.fws.gov/migratorybirds/pdf/management/EagleRuleRevisions-StatusReport.pdf#page=47&zoom=100,0,700

# Author: Sara Altman 
# Version: 2019-11-13

# Libraries
library(tidyverse)

# Parameters
file_eagle_nests <- here::here("data/eagles/eagle_nests.rds")
file_eagle_nests_tidy <- here::here("data/eagles/eagle_nests_tidy.rds")
#===============================================================================

se_2009 <- 
  c(Pacific = 514, Southwest = 57, `Rocky Mountains and Plains` = 57)

eagle_nests <- 
  tribble(
    ~region, ~`2007`, ~`2009`, ~ci_lower_2009, ~ci_upper_2009,
    "Pacific", 1039, 2587,     2073,           3101,
    "Southwest", 51, 176,      119,            233,
    "Rocky Mountains and Plains", 200, 338, 281, 395
  ) 

eagle_nests %>% 
  select(-contains("ci")) %>% 
  write_rds(file_eagle_nests)

eagle_nests_tidy <-
  eagle_nests %>% 
  select(-contains("ci")) %>% 
  pivot_longer(cols = -region, names_to = "year", values_to = "num_nests") %>% 
  write_rds(file_eagle_nests_tidy)

