# Migration data

# Author: Sara Altman
# Version: 2019-11-14

# Libraries
library(tidyverse)
library(readxl)

# Parameters
file_migration_answers <- 
  fs::path(
    admin::dir_github(), 
    "stanford-datalab", 
    "data", 
    "migration", 
    "answers.rds"
  )

YEAR <- 2017

destinations <- c("Albania", "Bulgaria", "Romania")
origins <- vars("Afghanistan", "Canada", "India", "Japan", "South Africa")
file_out <- here::here("data/migration/migration_2017.rds")
#===============================================================================

migration <- read_rds(file_migration_answers)$q1

v <-
  migration %>% 
  mutate_all(na_if, "..") %>% 
  filter(dest %in% destinations, year == YEAR) %>% 
  select(dest, !!!origins) %>% 
  arrange(dest) %>% 
  write_rds(file_out)
