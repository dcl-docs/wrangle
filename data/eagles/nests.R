# Eagle nests data from US Fish and Wildlife

# Source: https://www.fws.gov/migratorybirds/pdf/management/EagleRuleRevisions-StatusReport.pdf#page=47&zoom=100,0,700

# Author: Sara Altman 
# Version: 2019-11-13

# Libraries
library(tidyverse)

# Parameters
file_eagle_nests <- here::here("data/eagles/eagle_nests.rds")
file_eagle_nests_tidy <- here::here("data/eagles/eagle_nests_tidy.rds")
file_eagle_nests_tidy_ci <- here::here("data/eagles/eagle_nests_tidy_ci.rds")
#===============================================================================

se_2009 <- 
  c(Pacific = 514, Southwest = 57, `Rocky Mountains and Plains` = 57)

eagle_nests <- 
  tribble(
    ~region, ~`2007`, ~`2009`,
    "Pacific", 1039, 2587, 
    "Southwest", 51, 176,
    "Rocky Mountains and Plains", 200, 338
  ) %>% 
  write_rds(file_eagle_nests)

eagle_nests_tidy <-
  eagle_nests %>% 
  pivot_longer(cols = -region, names_to = "year", values_to = "num_nests") %>% 
  write_rds(file_eagle_nests_tidy)

eagle_nests_tidy %>% 
  mutate(se = if_else(year == 2009, se_2009[region], NA_real_)) %>% 
  write_rds(file_eagle_nests_tidy_ci)
