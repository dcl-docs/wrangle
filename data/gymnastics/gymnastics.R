# Gymnastics data from Wikipedia

# Author: Sara Altman
# Version: 2019-11-20

# Libraries
library(tidyverse)
library(rvest)



# Parameters
file_out_1 <- here::here("data/gymnastics/gymnastics_1.rds")
file_out_2 <- here::here("data/gymnastics/gymnastics_2.rds")
file_out_3 <- here::here("data/gymnastics/gymnastics_3.rds")
file_out_4 <- here::here("data/gymnastics/gymnastics_4.rds")
file_out_5 <- here::here("data/gymnastics/gymnastics_5.rds")

selectors <-
  c(
    women_2012 = "#mw-content-text > div > table:nth-child(17)",
    women_2016 = "#mw-content-text > div > table:nth-child(12)",
    men_2012 = "#mw-content-text > div > table.wikitable",
    men_2016 = "#mw-content-text > div > table.wikitable"
  )

urls <-
  c(
    women_2012 = 
      "https://en.wikipedia.org/wiki/Gymnastics_at_the_2012_Summer_Olympics_%E2%80%93_Women%27s_artistic_team_all-around",
    women_2016 = 
      "https://en.wikipedia.org/wiki/Gymnastics_at_the_2016_Summer_Olympics_%E2%80%93_Women%27s_artistic_team_all-around",
    men_2012 = 
      "https://en.wikipedia.org/wiki/Gymnastics_at_the_2012_Summer_Olympics_%E2%80%93_Men%27s_artistic_team_all-around",
    men_2016 = 
      "https://en.wikipedia.org/wiki/Gymnastics_at_the_2016_Summer_Olympics_%E2%80%93_Men%27s_artistic_team_all-around"
  )

ranks_women <-
  list(
    `2012` = 
      c(
        "United States" = 1L,
        "Russia" = 2L,
        "China" = 4L
      ),
    `2016` = 
      c(
        "United States" = 1L,
        "Russia" = 2L,
        "China" = 3L
      )
  )

countries <- c("United States", "Russia", "China")
#===============================================================================
extract_score <- function(x) {
  str_extract(x, "\\d+.\\d+") %>% as.double()
}

read_score_data <- function(url, selector, remove_rows, ...) {
  url %>% 
    read_html() %>% 
    html_node(css = selector) %>% 
    html_table(fill = TRUE, header = FALSE) %>% 
    as_tibble() %>% 
    slice(-remove_rows) %>% 
    select(...) %>% 
    filter(country %in% countries) %>% 
    mutate_at(vars(-country), extract_score) %>% 
    pivot_longer(cols = -country, names_to = "event", values_to = "score")
}

combine_2012_2016 <- function(df_2012, df_2016) {
  df_2012 %>% 
    bind_rows(`2012` = ., `2016` = df_2016, .id = "year")
}


women_2016 <-
  read_score_data(
    urls["women_2016"], 
    selectors["women_2016"], 
    remove_rows = 1, 
    country = X2, 
    vault = X3, 
    floor = X6
  ) 

men_2016 <-
  read_score_data(
    urls["men_2016"],
    selectors["men_2016"],
    remove_rows = c(1:3),
    country = X1, 
    floor = X2, 
    vault = X8
  )

women_2012 <-
  read_score_data(
    urls["women_2012"], 
    selectors["women_2012"],
    remove_rows = 1,
    country = X2, 
    vault = X3, 
    floor = X6
  )

men_2012 <-
  read_score_data(
    urls["men_2012"], 
    selectors["men_2012"],
    remove_rows = c(1:3),
    country = X1, 
    floor = X2, 
    vault = X8
  ) 

# Women's 2016
women_2016 %>%  
  pivot_wider(
    names_from = event, 
    names_prefix = "score_", 
    values_from = score
  ) %>% 
  write_rds(file_out_1)

# Women's 2016 and 2012
women_2012_2016 <-
  combine_2012_2016(women_2012, women_2016) 

women_2012_2016 %>% 
  pivot_wider(
    names_from = c(event, year), 
    names_sep = "_", 
    values_from = score
  ) %>% 
  write_rds(file_out_2)

all <-
  women_2012_2016 %>% 
  bind_rows(
    `f` = .,
    `m` = combine_2012_2016(men_2012, men_2016),
    .id = "gender"
  ) %>% 
  pivot_wider(
    names_from = c(event, year, gender), 
    names_sep = "_", 
    values_from = score
  ) %>% 
  select(
    country, 
    vault_2012_f, 
    vault_2012_m, 
    vault_2016_f, 
    vault_2016_m, 
    everything()
  ) %>% 
  write_rds(file_out_3)

women_2012_2016 %>% 
  pivot_wider(
    names_from = c(event, year), 
    names_sep = "", 
    values_from = score
  ) %>% 
  write_rds(file_out_4)

women_2012_total <-
  read_score_data(
    urls["women_2012"], 
    selectors["women_2012"],
    remove_rows = 1,
    country = X2, 
    total = X7
  )

women_2016_total <-
  read_score_data(
    urls["women_2016"], 
    selectors["women_2016"], 
    remove_rows = 1, 
    country = X2, 
    total = X7
  ) 

women_2012_total %>% 
  combine_2012_2016(women_2016_total) %>% 
  pivot_wider(
    names_from = event,
    values_from = score
  ) %>% 
  mutate(
    rank = map2_dbl(year, country, ~ ranks_women[[.x]][.y])
  ) %>% 
  pivot_longer(
    cols = total:rank,
    names_to = "variable",
    values_to = "value"
  ) %>% 
  unite(col = "variable", variable, year, sep = "-") %>% 
  select(country, variable, value) %>% 
  write_rds(file_out_5)
  
