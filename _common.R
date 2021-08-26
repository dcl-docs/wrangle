set.seed(858)

options(
  digits = 3,
  dplyr.print_max = 6,
  dplyr.print_min = 6,
  dplyr.summarise.inform = FALSE
)

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  fig.align = 'center',
  fig.asp = 0.618,  # 1 / phi
  fig.show = "hold"
)

image_dpi <- 125
