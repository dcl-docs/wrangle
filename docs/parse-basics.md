
# Parsing

So far you've worked with data sets that have been bundled in R packages, or have been created with `tibble()` or `tribble()`. Now it's time to learn how to read simple flat files from disk. To do this, we'll use functions from [readr](http://readr.tidyverse.org). readr is one of the core tidyverse packages, so you won't usually load it explicitly.


```r
library(tidyverse)
```

## Delimited files

In this section, we're going to focus on delimited files. Delimited files have a __delimiter__ between each value. Two types make up the majority of delimited files that you'll see in the wild: CSV (comma separated) and TSV (tab separated). We'll focus on CSV files, but everything you'll learn applies equally to TSVs, replacing commas with tabs.

A typical CSV file looks something like this:

```
Sepal.Length,Sepal.Width,Petal.Length,Petal.Width,Species
5.1,3.5,1.4,0.2,setosa
4.9,3,1.4,0.2,setosa
4.7,3.2,1.3,0.2,setosa
4.6,3.1,1.5,0.2,setosa
5,3.6,1.4,0.2,setosa
5.4,3.9,1.7,0.4,setosa
4.6,3.4,1.4,0.3,setosa
5,3.4,1.5,0.2,setosa
```

Note that:

* The first line gives the column names.
* Each subsequent line is one row of data.
* Each value is separated by a comma (hence the name).

Typically, you can recognize a CSV file by its extension: `.csv`. But beware! Sometimes the extension lies, and if you're getting weird errors when reading a file, it's a good idea to peek inside the file using `readr::read_lines()` and `writeLines()`, specifying the `n_max` argument to just look at the first few lines. (You'll learn more about `writeLines()` when we get to strings; for now just remember it's a useful tool for printing lines to the screen.)


```r
"data/heights.csv" %>% 
  read_lines(n_max = 10) %>%
  writeLines()
#> "earn","height","sex","ed","age","race"
#> 50000,74.4244387818035,"male",16,45,"white"
#> 60000,65.5375428255647,"female",16,58,"white"
#> 30000,63.6291977374349,"female",16,29,"white"
#> 50000,63.1085616752971,"female",16,91,"other"
#> 51000,63.4024835710879,"female",17,39,"white"
#> 9000,64.3995075440034,"female",15,26,"white"
#> 29000,61.6563258264214,"female",12,49,"white"
#> 32000,72.6985437364783,"male",17,46,"white"
#> 2000,72.0394668497611,"male",15,21,"hispanic"
```

This file illustrates another feature present in many CSV files: some values are surrounded by quotes. Confusingly, this isn't a guarantee that the value is a string: some CSV files also surround numbers in quotes too.  As you work with more CSV files, you'll discover there are few hard and fast rules: for pretty much every crazy thing that you can imagine, someone has done it in a CSV file somewhere.

## `read_csv()`

The workhorse for reading in CSV files is called `read_csv()`. You give it a path to a CSV file and it gives you back a tibble:


```r
heights <- read_csv("data/heights.csv")
#> Rows: 1192 Columns: 6
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (2): sex, race
#> dbl (4): earn, height, ed, age
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
heights
#> # A tibble: 1,192 × 6
#>    earn height sex       ed   age race 
#>   <dbl>  <dbl> <chr>  <dbl> <dbl> <chr>
#> 1 50000   74.4 male      16    45 white
#> 2 60000   65.5 female    16    58 white
#> 3 30000   63.6 female    16    29 white
#> 4 50000   63.1 female    16    91 other
#> 5 51000   63.4 female    17    39 white
#> 6  9000   64.4 female    15    26 white
#> # … with 1,186 more rows
```

If you are very lucky, you can point `read_csv()` at a file and it just works. But this is usually the exception, not the rule, and often you'll need to tweak some arguments.

The most important arguments to `read_csv()` are:

*   `col_names`: Usually `col_names = TRUE`, the default, which tells `read_csv()` that the first line of the file contains the column names. If there aren't any column, names set `col_names = FALSE` or supply a character vector telling `read_csv()` what they should be `col_names = c("x", "y", "z")`.
    
*   `col_types`: You might have noticed that when we called `read_csv()` above it printed out a list of column "specifications". That describes how readr converts each column into an data structure. readr uses some pretty good heuristics to guess the type, but sometimes the heuristics fail and you'll need to supply the truth. You'll learn more about that later in the course.
    
*   It's fairly common to encounter CSV files that have a bunch of lines at the top you don't wish to parse. You can use `skip = n` to skip the first n lines, or `comment = "#"` to ignore all lines that start with `#`.

*   `read_csv()` expects missing values to be supplied as `""` or `"NA"`. If your file uses a different convention, use the `na` argument to override the default.

You'll get to practice using these arguments in the exercises.
