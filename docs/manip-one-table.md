
# Other single-table verbs

You've learned the most important verbs for data analysis: `filter()`, `mutate()`, `group_by()` and `summarize()`. There are a number of other verbs that are not quite as important but still come in handy from time-to-time. The goal of this section is to familiarize you with their purpose and basic operation.


```r
library(tidyverse)
library(nycflights13)
```

## Select

Most of the datasets you'll work with in this class only have a relatively small number of variables, and generally you don't need to reduce further. In real life, you'll sometimes encounter datasets with hundreds or even thousands of variables, and the first challenge is just to narrow down to a useful subset. Solving that problem is the job of `select()`.

`select()` allows you to work with column names using a handful of helper functions:

* `starts_with("x")` and `ends_with("x")` select variables that start with a
  common prefix or end with a common suffix.
  
* `contains("x")` selects variables that contain a phrase. `matches("x.y")`
  select all variables that match a given regular expression (which you'll 
  learn about later in the course).
  
* `a:e` selects all variables from variable `a` to variable `e` inclusive.

You can also select a single variable just by using its name directly.


```r
flights %>% 
  select(year:day, ends_with("delay"))
#> # A tibble: 336,776 × 5
#>    year month   day dep_delay arr_delay
#>   <int> <int> <int>     <dbl>     <dbl>
#> 1  2013     1     1         2        11
#> 2  2013     1     1         4        20
#> 3  2013     1     1         2        33
#> 4  2013     1     1        -1       -18
#> 5  2013     1     1        -6       -25
#> 6  2013     1     1        -4        12
#> # … with 336,770 more rows
```

To remove variables from selection, put an exclamation point `!` in front of the expression.


```r
flights %>% 
  select(!starts_with("dep"))
#> # A tibble: 336,776 × 17
#>    year month   day sched_dep_time arr_time sched_arr_time arr_delay carrier
#>   <int> <int> <int>          <int>    <int>          <int>     <dbl> <chr>  
#> 1  2013     1     1            515      830            819        11 UA     
#> 2  2013     1     1            529      850            830        20 UA     
#> 3  2013     1     1            540      923            850        33 AA     
#> 4  2013     1     1            545     1004           1022       -18 B6     
#> 5  2013     1     1            600      812            837       -25 DL     
#> 6  2013     1     1            558      740            728        12 UA     
#> # … with 336,770 more rows, and 9 more variables: flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>
```

## Rename

To change the name of a variable use `df %>% rename(new_name = old_name)`. If you have trouble remembering which sides old and new go on, remember it's the same order as `mutate()`.


```r
flights %>% 
  rename(tail_num = tailnum)
#> # A tibble: 336,776 × 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     1      517            515         2      830            819
#> 2  2013     1     1      533            529         4      850            830
#> 3  2013     1     1      542            540         2      923            850
#> 4  2013     1     1      544            545        -1     1004           1022
#> 5  2013     1     1      554            600        -6      812            837
#> 6  2013     1     1      554            558        -4      740            728
#> # … with 336,770 more rows, and 11 more variables: arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tail_num <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

If you're selecting and renaming, note that you can also use `select()` to rename. This sometimes allows you to save a step.


```r
flights %>% 
  select(year:day, tail_num = tailnum)
#> # A tibble: 336,776 × 4
#>    year month   day tail_num
#>   <int> <int> <int> <chr>   
#> 1  2013     1     1 N14228  
#> 2  2013     1     1 N24211  
#> 3  2013     1     1 N619AA  
#> 4  2013     1     1 N804JB  
#> 5  2013     1     1 N668DN  
#> 6  2013     1     1 N39463  
#> # … with 336,770 more rows
```

## Change column order

Use `relocate()` to change column positions. It uses the same syntax as `select()`. The arguments `.before` and `.after` indicate where to move columns. If neither argument is supplied, columns are moved before the first column.


```r
flights %>% 
  relocate(carrier, flight, origin, dest, .after = dep_time)
#> # A tibble: 336,776 × 19
#>    year month   day dep_time carrier flight origin dest  sched_dep_time
#>   <int> <int> <int>    <int> <chr>    <int> <chr>  <chr>          <int>
#> 1  2013     1     1      517 UA        1545 EWR    IAH              515
#> 2  2013     1     1      533 UA        1714 LGA    IAH              529
#> 3  2013     1     1      542 AA        1141 JFK    MIA              540
#> 4  2013     1     1      544 B6         725 JFK    BQN              545
#> 5  2013     1     1      554 DL         461 LGA    ATL              600
#> 6  2013     1     1      554 UA        1696 EWR    ORD              558
#> # … with 336,770 more rows, and 10 more variables: dep_delay <dbl>,
#> #   arr_time <int>, sched_arr_time <int>, arr_delay <dbl>, tailnum <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

## Transmute

Transmute is a minor variation of `mutate()`. The main difference is that it drops any variables that you didn't explicitly mention. It's a useful shortcut for `mutate()` + `select()`.


```r
df <- tibble(x = 1:3, y = 3:1)

# mutate() keeps x and y
df %>% 
  mutate(z = x + y)
#> # A tibble: 3 × 3
#>       x     y     z
#>   <int> <int> <int>
#> 1     1     3     4
#> 2     2     2     4
#> 3     3     1     4

# transmute() drops x and y
df %>% 
  transmute(z = x + y)
#> # A tibble: 3 × 1
#>       z
#>   <int>
#> 1     4
#> 2     4
#> 3     4
```

## Arrange

`arrange()` lets you change the order of the rows. To put a column in descending order, use `desc()`.


```r
flights %>% 
  arrange(desc(dep_delay))
#> # A tibble: 336,776 × 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     9      641            900      1301     1242           1530
#> 2  2013     6    15     1432           1935      1137     1607           2120
#> 3  2013     1    10     1121           1635      1126     1239           1810
#> 4  2013     9    20     1139           1845      1014     1457           2210
#> 5  2013     7    22      845           1600      1005     1044           1815
#> 6  2013     4    10     1100           1900       960     1342           2211
#> # … with 336,770 more rows, and 11 more variables: arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>

flights %>% 
  arrange(year, month, day)
#> # A tibble: 336,776 × 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     1      517            515         2      830            819
#> 2  2013     1     1      533            529         4      850            830
#> 3  2013     1     1      542            540         2      923            850
#> 4  2013     1     1      544            545        -1     1004           1022
#> 5  2013     1     1      554            600        -6      812            837
#> 6  2013     1     1      554            558        -4      740            728
#> # … with 336,770 more rows, and 11 more variables: arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

## Distinct

`distinct()` removes duplicates from a dataset. The result is ordered by first occurence in original dataset.


```r
flights %>% 
  distinct(carrier, flight)
#> # A tibble: 5,725 × 2
#>   carrier flight
#>   <chr>    <int>
#> 1 UA        1545
#> 2 UA        1714
#> 3 AA        1141
#> 4 B6         725
#> 5 DL         461
#> 6 UA        1696
#> # … with 5,719 more rows
```

## Slice rows

`slice()` allows you to pick rows by position, by group.


```r
# Rows 10 - 14
flights %>% 
  slice(10:14)
#> # A tibble: 5 × 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     1      558            600        -2      753            745
#> 2  2013     1     1      558            600        -2      849            851
#> 3  2013     1     1      558            600        -2      853            856
#> 4  2013     1     1      558            600        -2      924            917
#> 5  2013     1     1      558            600        -2      923            937
#> # … with 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>,
#> #   hour <dbl>, minute <dbl>, time_hour <dttm>
```

`slice_head()` and `slice_tail()` show the first (or last) rows of the data frame or its groups. 


```r
# First 5 flights to each destination
flights %>% 
  select(year:dep_time, carrier, flight, origin, dest) %>% 
  group_by(dest) %>%
  slice_head(n = 5)
#> # A tibble: 517 × 8
#> # Groups:   dest [105]
#>    year month   day dep_time carrier flight origin dest 
#>   <int> <int> <int>    <int> <chr>    <int> <chr>  <chr>
#> 1  2013    10     1     1955 B6          65 JFK    ABQ  
#> 2  2013    10     2     2010 B6          65 JFK    ABQ  
#> 3  2013    10     3     1955 B6          65 JFK    ABQ  
#> 4  2013    10     4     2017 B6          65 JFK    ABQ  
#> 5  2013    10     5     1959 B6          65 JFK    ABQ  
#> 6  2013    10     1     1149 B6        1191 JFK    ACK  
#> # … with 511 more rows

# Last 5 flights overall
flights %>% 
  select(year:dep_time, carrier, flight, origin, dest) %>% 
  slice_tail(n = 5)
#> # A tibble: 5 × 8
#>    year month   day dep_time carrier flight origin dest 
#>   <int> <int> <int>    <int> <chr>    <int> <chr>  <chr>
#> 1  2013     9    30       NA 9E        3393 JFK    DCA  
#> 2  2013     9    30       NA 9E        3525 LGA    SYR  
#> 3  2013     9    30       NA MQ        3461 LGA    BNA  
#> 4  2013     9    30       NA MQ        3572 LGA    CLE  
#> 5  2013     9    30       NA MQ        3531 LGA    RDU
```

`slice_min()` and `slice_max()` select rows by the highest or lowest values of a variable. By default all ties are returned, in which case you may receive more rows than you ask for.


```r
# Flights with the last time_hour
flights %>% 
  select(time_hour, carrier, flight, origin, dest) %>%
  slice_max(n = 1, time_hour)
#> # A tibble: 5 × 5
#>   time_hour           carrier flight origin dest 
#>   <dttm>              <chr>    <int> <chr>  <chr>
#> 1 2013-12-31 23:00:00 B6         839 JFK    BQN  
#> 2 2013-12-31 23:00:00 DL         412 JFK    SJU  
#> 3 2013-12-31 23:00:00 B6        1389 EWR    SJU  
#> 4 2013-12-31 23:00:00 B6        1503 JFK    SJU  
#> 5 2013-12-31 23:00:00 B6         745 JFK    PSE
```

## Sample

When working with very large datasets, sometimes it's convenient to reduce to a smaller dataset, just by taking a random sample. That's the job of `slice_sample()`. You use the `n` argument to select the same number of observations from each group. You use the `prop` argument to select the same proportion.


```r
# Popular destinations
popular_dest <- 
  flights %>%
  group_by(dest) %>%
  filter(n() >= 1000)

# Dataset with a random sample of 100 flights to each destination
popular_dest %>% 
  slice_sample(n = 100)
#> # A tibble: 5,800 × 19
#> # Groups:   dest [58]
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     8    16     1543           1545        -2     1807           1806
#> 2  2013     4    22     1537           1520        17     1835           1745
#> 3  2013    10    29     1917           1930       -13     2152           2159
#> 4  2013    11    14     1747           1729        18     2007           1955
#> 5  2013     4    26      703            700         3      940            931
#> 6  2013    12    17       NA           1240        NA       NA           1513
#> # … with 5,794 more rows, and 11 more variables: arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>

# Dataset with a random sample of 1% of the flights to each destination
popular_dest %>% 
  slice_sample(prop = 0.01)
#> # A tibble: 3,176 × 19
#> # Groups:   dest [58]
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     9     3     1955           1959        -4     2151           2230
#> 2  2013     8     6     1924           1925        -1     2153           2156
#> 3  2013     7    29     1256           1300        -4     1521           1519
#> 4  2013     9     6      559            600        -1      811            815
#> 5  2013     9    12      615            600        15      839            829
#> 6  2013     6     3     1543           1545        -2     1844           1823
#> # … with 3,170 more rows, and 11 more variables: arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

