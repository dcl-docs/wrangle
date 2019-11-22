# Sibling data

# Author: Name
# Version: 2019-11-21

# Libraries
library(tidyverse)

# Parameters
file_out <- here::here("data/twins/twins.rds")
#===============================================================================

tribble(
  ~family, ~name, ~n,
  "Kelly", "Mark", 1,
  "Kelly", "Scott", 2,
  "Quin",  "Tegan", 1,
  "Quin",  "Sara", 2
) %>% 
  write_rds(file_out)
