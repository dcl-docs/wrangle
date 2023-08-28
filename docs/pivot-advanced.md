
# Advanced pivoting



`pivot_longer()` and `pivot_wider()` are very flexible, and can easily tidy a wide variety of non-tidy datasets. The previous chapter only covered the basics. In this chapter, we'll explore this flexibility by introducing some of the pivot functions' advanced functionality.

## Longer

### Types

By default, `pivot_longer()` creates the `names_to` column as a character variable. For example, when we `pivot_longer()` `example_eagle_nests`, `year` becomes a character column. 


```r
example_eagle_nests %>% 
  pivot_longer(
    cols = c(`2007`, `2009`), 
    names_to = "year", 
    values_to = "num_nests"
  )
#> # A tibble: 6 × 3
#>   region                     year  num_nests
#>   <chr>                      <chr>     <dbl>
#> 1 Pacific                    2007       1039
#> 2 Pacific                    2009       2587
#> 3 Southwest                  2007         51
#> 4 Southwest                  2009        176
#> 5 Rocky Mountains and Plains 2007        200
#> 6 Rocky Mountains and Plains 2009        338
```

It's probably more useful to store `year` as an integer. We can tell `pivot_longer()` our desired type for the `names_to` column by using the optional `names_transform` argument. 

`names_transform` takes a named list of column name and function pairs. For example, here's how we would create `year` as an integer column:


```r
example_eagle_nests %>% 
  pivot_longer(
    cols = c(`2007`, `2009`), 
    names_to = "year", 
    names_transform = list(year = as.integer),
    values_to = "num_nests"
  )
#> # A tibble: 6 × 3
#>   region                      year num_nests
#>   <chr>                      <int>     <dbl>
#> 1 Pacific                     2007      1039
#> 2 Pacific                     2009      2587
#> 3 Southwest                   2007        51
#> 4 Southwest                   2009       176
#> 5 Rocky Mountains and Plains  2007       200
#> 6 Rocky Mountains and Plains  2009       338
```

If we wanted `year` to be a double, we would use the following:


```r
example_eagle_nests %>% 
  pivot_longer(
    cols = c(`2007`, `2009`), 
    names_to = "year", 
    names_transform = list(year = as.double),
    values_to = "num_nests"
  )
#> # A tibble: 6 × 3
#>   region                      year num_nests
#>   <chr>                      <dbl>     <dbl>
#> 1 Pacific                     2007      1039
#> 2 Pacific                     2009      2587
#> 3 Southwest                   2007        51
#> 4 Southwest                   2009       176
#> 5 Rocky Mountains and Plains  2007       200
#> 6 Rocky Mountains and Plains  2009       338
```

`pivot_longer()` also has a `values_transform` argument that controls the type of the `values_to` column. You specify `values_transform` in the same way as `names_transform`. For example, say we wanted to change `num_nests` from its default type (double) to an integer.


```r
example_eagle_nests %>% 
  pivot_longer(
    cols = c(`2007`, `2009`), 
    names_to = "year", 
    names_transform = list(year = as.integer),
    values_to = "num_nests",
    values_transform = list(num_nests = as.integer)
  )
#> # A tibble: 6 × 3
#>   region                      year num_nests
#>   <chr>                      <int>     <int>
#> 1 Pacific                     2007      1039
#> 2 Pacific                     2009      2587
#> 3 Southwest                   2007        51
#> 4 Southwest                   2009       176
#> 5 Rocky Mountains and Plains  2007       200
#> 6 Rocky Mountains and Plains  2009       338
```

### Prefixes

Sometimes, the columns you want to pivot will contain extra information, either in their names or their values. For example, `example_gymnastics_1` contains data on the scores of three countries' women's Olympic gymnastic teams in 2016. 


```r
example_gymnastics_1
#> # A tibble: 3 × 3
#>   country       score_vault score_floor
#>   <chr>               <dbl>       <dbl>
#> 1 United States        46.9        46.0
#> 2 Russia               45.7        42.0
#> 3 China                44.3        42.1
```

To tidy `example_gymnastics_1`, we need to pivot `score_vault` and `score_floor`.


```r
example_gymnastics_1 %>% 
  pivot_longer(
    cols = !country, 
    names_to = "event", 
    values_to = "score"
  )
#> # A tibble: 6 × 3
#>   country       event       score
#>   <chr>         <chr>       <dbl>
#> 1 United States score_vault  46.9
#> 2 United States score_floor  46.0
#> 3 Russia        score_vault  45.7
#> 4 Russia        score_floor  42.0
#> 5 China         score_vault  44.3
#> 6 China         score_floor  42.1
```

However, `score_vault` isn't really a value of `event`. It would be better for the values to be `"vault"` and `"floor"`. We can remove the `"score_"` prefix with `pivot_longer()'`s `names_prefix` argument.


```r
example_gymnastics_1 %>% 
  pivot_longer(
    cols = !country, 
    names_to = "event", 
    names_prefix = "score_",
    values_to = "score"
  )
#> # A tibble: 6 × 3
#>   country       event score
#>   <chr>         <chr> <dbl>
#> 1 United States vault  46.9
#> 2 United States floor  46.0
#> 3 Russia        vault  45.7
#> 4 Russia        floor  42.0
#> 5 China         vault  44.3
#> 6 China         floor  42.1
```

### Multiple values

`example_gymnastics_2` includes data on both the 2012 and 2016 Olympics.


```r
example_gymnastics_2
#> # A tibble: 3 × 5
#>   country       vault_2012 floor_2012 vault_2016 floor_2016
#>   <chr>              <dbl>      <dbl>      <dbl>      <dbl>
#> 1 United States       48.1       45.4       46.9       46.0
#> 2 Russia              46.4       41.6       45.7       42.0
#> 3 China               44.3       40.8       44.3       42.1
```

There are four variables in this non-tidy dataset: `country`, `event`, `year`, and `score`. To tidy the data, we'll need to pivot `vault_2012` through `floor_2016`. In contrast to other examples we've seen so far, though, each of these variable names contains _two_ values: a `event` value and a `year` value. If we `pivot_longer()` as usual, both of these values will get placed in the same cell:


```r
example_gymnastics_2 %>% 
  pivot_longer(
    cols = !country,
    names_to = "event_year",
    values_to = "score"
  )
#> # A tibble: 12 × 3
#>   country       event_year score
#>   <chr>         <chr>      <dbl>
#> 1 United States vault_2012  48.1
#> 2 United States floor_2012  45.4
#> 3 United States vault_2016  46.9
#> 4 United States floor_2016  46.0
#> 5 Russia        vault_2012  46.4
#> 6 Russia        floor_2012  41.6
#> # … with 6 more rows
```

`event_year` contains two variables, and so the result isn't tidy. Instead, we want `pivot_longer()` to split each pivoted variable name into two, placing `"vault"` or `"floor"` into an `event` variable and `2012` or `2016` into a `year` variable. 

We'll need to make the following two changes to our `pivot_longer()` call:

* Change `names_to` to be a vector of two names: `c("event", "year)`. This will tell `pivot_longer()` to create two variables from the column names instead of one.
* Use the `names_sep` argument to tell `pivot_longer()` what separates an `event` value from a `year` in each of the column names. Here, that's an underscore (`_`). 


```r
example_gymnastics_2 %>% 
  pivot_longer(
    cols = !country,
    names_to = c("event", "year"),
    names_sep = "_",
    values_to = "score"
  )
#> # A tibble: 12 × 4
#>   country       event year  score
#>   <chr>         <chr> <chr> <dbl>
#> 1 United States vault 2012   48.1
#> 2 United States floor 2012   45.4
#> 3 United States vault 2016   46.9
#> 4 United States floor 2016   46.0
#> 5 Russia        vault 2012   46.4
#> 6 Russia        floor 2012   41.6
#> # … with 6 more rows
```

`pivot_longer()` created three variables, instead of the default two: `event`, `year`, and `score`. Now, the data is tidy.

We can extend this idea to work with any number of columns. `example_gymnastics_3` has three values stored in each column name: `event`, `year`, and `gender`.


```r
example_gymnastics_3
#> # A tibble: 3 × 9
#>   country       vault_2012_f vault_2012_m vault_2016_f vault_2016_m floor_2012_f
#>   <chr>                <dbl>        <dbl>        <dbl>        <dbl>        <dbl>
#> 1 United States         48.1         46.6         46.9         45.9         45.4
#> 2 Russia                46.4         46.9         45.7         46.0         41.6
#> 3 China                 44.3         48.3         44.3         45           40.8
#> # … with 3 more variables: floor_2012_m <dbl>, floor_2016_f <dbl>,
#> #   floor_2016_m <dbl>
```

`names_sep` is still `_`, but we'll need to change `names_to` to include `"gender"`. 


```r
example_gymnastics_3 %>% 
  pivot_longer(
    cols = !country,
    names_to = c("event", "year", "gender"),
    names_sep = "_",
    values_to = "score"
  )
#> # A tibble: 24 × 5
#>   country       event year  gender score
#>   <chr>         <chr> <chr> <chr>  <dbl>
#> 1 United States vault 2012  f       48.1
#> 2 United States vault 2012  m       46.6
#> 3 United States vault 2016  f       46.9
#> 4 United States vault 2016  m       45.9
#> 5 United States floor 2012  f       45.4
#> 6 United States floor 2012  m       45.3
#> # … with 18 more rows
```

Finally, what if there isn't a separator like `_` in the column names? 


```r
example_gymnastics_4 
#> # A tibble: 3 × 5
#>   country       vault2012 floor2012 vault2016 floor2016
#>   <chr>             <dbl>     <dbl>     <dbl>     <dbl>
#> 1 United States      48.1      45.4      46.9      46.0
#> 2 Russia             46.4      41.6      45.7      42.0
#> 3 China              44.3      40.8      44.3      42.1
```

Instead of using `names_sep`, we can a related `pivot_longer()` argument: `names_pattern`. `names_pattern` is more flexible than `names_sep` because it allows regular expression groups, matching each group with a variable from `names_to`. 

For `example_gymnastics_4`, we want to create two variables from the column names: `event` and `year`. This means `names_pattern` needs two groups. Here's a regular expression we could use:


```r
"([A-Za-z]+)(\\d+)"
```

`"([A-Za-z]+)"` matches only letters, so will pull out just `"vault"` or `"floor"`. `"(\\d+)"` matches digits and will pull out `2012` or `2016`. 

Here's the call to `pivot_longer()`:


```r
example_gymnastics_4 %>% 
  pivot_longer(
    cols = !country,
    names_to = c("event", "year"),
    names_pattern = "([A-Za-z]+)(\\d+)",
    values_to = "score"
  )
#> # A tibble: 12 × 4
#>   country       event year  score
#>   <chr>         <chr> <chr> <dbl>
#> 1 United States vault 2012   48.1
#> 2 United States floor 2012   45.4
#> 3 United States vault 2016   46.9
#> 4 United States floor 2016   46.0
#> 5 Russia        vault 2012   46.4
#> 6 Russia        floor 2012   41.6
#> # … with 6 more rows
```

`pivot_longer()` successfully separates the events from the years. 

## Wider

### Prefixes

Like `pivot_longer()`, `pivot_wider()` also has a `names_prefix` argument. However, it adds a prefix instead of removing one.

`example_twins` contains some data on two sets of (real) twins. `n` defines the birth order.


```r
example_twins
#> # A tibble: 4 × 3
#>   family name      n
#>   <chr>  <chr> <dbl>
#> 1 Kelly  Mark      1
#> 2 Kelly  Scott     2
#> 3 Quin   Tegan     1
#> 4 Quin   Sara      2
```

If we `pivot_wider()` without a prefix, we'll get numbers as column names, which isn't very informative.


```r
example_twins %>% 
  pivot_wider(names_from = "n", values_from = "name")
#> # A tibble: 2 × 3
#>   family `1`   `2`  
#>   <chr>  <chr> <chr>
#> 1 Kelly  Mark  Scott
#> 2 Quin   Tegan Sara
```

We can use `names_prefix` to add an informative prefix.


```r
example_twins %>% 
  pivot_wider(
    names_from = "n", 
    names_prefix = "twin_", 
    values_from = "name"
  )
#> # A tibble: 2 × 3
#>   family twin_1 twin_2
#>   <chr>  <chr>  <chr> 
#> 1 Kelly  Mark   Scott 
#> 2 Quin   Tegan  Sara
```

### Multiple values

Earlier, we showed how you can create multiple columns from data stored in column names using `pivot_longer()`. Analogously, you can use `pivot_wider()` to create column names that combine values from multiple columns.

For example, take the following modified subset of the American Community Survey data from last chapter:


```r
example_acs_2
#> # A tibble: 8 × 5
#>   geoid name    variable    measure    value
#>   <chr> <chr>   <chr>       <chr>      <dbl>
#> 1 01    Alabama pop_renter  estimate 1434765
#> 2 01    Alabama pop_renter  error      16736
#> 3 01    Alabama median_rent estimate     747
#> 4 01    Alabama median_rent error          3
#> 5 13    Georgia pop_renter  estimate 3592422
#> 6 13    Georgia pop_renter  error      33385
#> # … with 2 more rows
```

The `measure` column indicates if a given row represents the estimate of the variable or the margin of error. We might want each combination of `variable` and `measure` to become the name of a new variable (i.e., `pop_renter_estimate`, `pop_renter_error`, `median_rent_estimate`, `median_rent_error`). Recall that `pivot_wider()`'s `names_from` argument controls which column's values are used for the new column names. If we supply multiple columns to `names_from`, `pivot_wider()` will create one new column for each unique combination. 


```r
example_acs_2 %>% 
  pivot_wider(
    names_from = c(variable, measure), 
    values_from = value
  )
#> # A tibble: 2 × 6
#>   geoid name    pop_renter_estimate pop_renter_error median_rent_estimate
#>   <chr> <chr>                 <dbl>            <dbl>                <dbl>
#> 1 01    Alabama             1434765            16736                  747
#> 2 13    Georgia             3592422            33385                  927
#> # … with 1 more variable: median_rent_error <dbl>
```

By default, `pivot_wider()` will combine the two values with an underscore, but you can control the separator with `names_sep`. 

In `example_acs_2`, the names of our desired columns were stored across two variables: `variable` and `measure`. You might also encounter values stored across multiple variables. 


```r
example_acs_3
#> # A tibble: 4 × 5
#>   geoid name    variable    estimate error
#>   <chr> <chr>   <chr>          <dbl> <dbl>
#> 1 01    Alabama pop_renter   1434765 16736
#> 2 01    Alabama median_rent      747     3
#> 3 13    Georgia pop_renter   3592422 33385
#> 4 13    Georgia median_rent      927     3
```

Now, values of our desired variables (`pop_renter_esimate`, `pop_renter_error`, `median_rent_estimate`, and `median_rent_error`) are in two separate columns: `estimate` and `error`. We can specify both columns to `pivot_wider()`'s `values_from` argument.


```r
example_acs_3 %>% 
  pivot_wider(
    names_from = variable, 
    values_from = c(estimate, error)
  )
#> # A tibble: 2 × 6
#>   geoid name    estimate_pop_renter estimate_median_rent error_pop_renter
#>   <chr> <chr>                 <dbl>                <dbl>            <dbl>
#> 1 01    Alabama             1434765                  747            16736
#> 2 13    Georgia             3592422                  927            33385
#> # … with 1 more variable: error_median_rent <dbl>
```

`pivot_wider()` pivots `variable`, then creates columns by combining the value of measure with each column name specified in `values_from`. 

### `id_cols`

`pivot_wider()` has an additional argument `id_cols`, which is useful in some situations. To explain, we'll go over a brief example.

Here's another ACS dataset:


```r
example_acs_4
#> # A tibble: 6 × 5
#>   geoid name    variable    estimate error
#>   <chr> <chr>   <chr>          <dbl> <dbl>
#> 1 01    Alabama pop_housed   4731852    NA
#> 2 01    Alabama pop_renter   1434765 16736
#> 3 01    Alabama median_rent      747     3
#> 4 13    Georgia pop_housed   9943137    NA
#> 5 13    Georgia pop_renter   3592422 33385
#> 6 13    Georgia median_rent      927     3
```

Now, `variable` includes three variables: the total housed population (`"pop_housed"`), total renter population (`"pop_renter"`), and median rent (`"median_rent"`). However, `error` is only available for `"pop_renter"` and `"median_rent"`. Say that we don't want to pivot `error` because we don't need the margin of error data. Here's an attempt:


```r
example_acs_4 %>% 
  pivot_wider(
    names_from = variable,
    values_from = estimate
  )
#> # A tibble: 6 × 6
#>   geoid name    error pop_housed pop_renter median_rent
#>   <chr> <chr>   <dbl>      <dbl>      <dbl>       <dbl>
#> 1 01    Alabama    NA    4731852         NA          NA
#> 2 01    Alabama 16736         NA    1434765          NA
#> 3 01    Alabama     3         NA         NA         747
#> 4 13    Georgia    NA    9943137         NA          NA
#> 5 13    Georgia 33385         NA    3592422          NA
#> 6 13    Georgia     3         NA         NA         927
```

This probably isn't the result we want. `pivot_wider()` created one row for each `geoid`-`name`-`error` combination, thinking that `geoid`, `name`, and `error` all identify an observation. We can fix this by setting `id_cols`. 

`id_cols` controls which columns define an observation. By default, `id_cols` includes all columns not specified in `names_from` or `values_from`. Here, we want `pivot_wider()` to understand that each observation should be a state, defined by `geoid` and `name`. To fix the problem, we'll tell `pivot_longer()` that `error` should not be included in `id_cols`. 


```r
example_acs_4 %>% 
  pivot_wider(
    id_cols = !error,
    names_from = variable,
    values_from = estimate
  )
#> # A tibble: 2 × 5
#>   geoid name    pop_housed pop_renter median_rent
#>   <chr> <chr>        <dbl>      <dbl>       <dbl>
#> 1 01    Alabama    4731852    1434765         747
#> 2 13    Georgia    9943137    3592422         927
```

That looks a lot better! `pivot_wider()` threw out the `error` column and created one row for each state. 

