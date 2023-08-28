
# Google Sheets


```r
library(tidyverse)
library(googlesheets4)

# Sheet ID for Gapminder example
id_gapminder <- "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"
```

Google Sheets are a useful way to collect, store, and collaboratively work with data. The googlesheets4 package wraps the [Sheets API](https://developers.google.com/sheets/api), making it easy for you to work with Google Sheets in R.

The "4" in googlesheets4 refers to the most recent version (v4) of the Google Sheets API. There's also an R package called googlesheets, which uses an older version (v3) of the Google Sheets API. If you've worked with the googlesheets package previously, note that the Sheets API v3 is being shut down, so you'll need to switch over to googlesheets4.  

## Reading

Reading data stored in a Google sheet into R will probably be your most common use of googlesheets4. Here, we'll read in the data from our [example sheet](https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/), which contains data from [Gapminder](https://www.gapminder.org/). 

To read in the data, we need a way to identify the Google sheet. googlesheets4 supports multiple ways of identifying sheets, but we recommend using the sheet ID, as it's stable and concise. You can find the ID of a Google sheet in its URL:

<img src="images/googlesheets/sheet-id.png" width="9058" style="display: block; margin: auto;" />

If you want to extract an ID from a URL programmatically, you can also use the function `as_sheets_id()`.

We've stored the ID for the Gapminder sheet in the parameters section up at the top. Here it is:


```r
id_gapminder
#> [1] "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"
```

Now, we can use the googlesheets4 function `read_sheet()` to read in the data. `read_sheet()`'s first argument, `ss`, takes the sheet ID.


```r
read_sheet(ss = id_gapminder)
#> ✓ Reading from "test-gs-gapminder".
#> ✓ Range 'Africa'.
#> # A tibble: 624 × 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> 6 Algeria Africa     1977    58.0 17152804     4910.
#> # … with 618 more rows
```

Notice that the [original sheet](https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/) contains multiple sheets, one for each continent. We can list all these sheets by using the function `sheet_names()`.


```r
sheet_names(ss = id_gapminder)
#> [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania"
```

By default, `read_sheet()` reads  in the first sheet. Here, that's the Africa sheet. If we want to read in Asia, we can specify the `sheet` argument.


```r
read_sheet(ss = id_gapminder, sheet = "Asia")
#> ✓ Reading from "test-gs-gapminder".
#> ✓ Range ''Asia''.
#> # A tibble: 396 × 6
#>   country     continent  year lifeExp      pop gdpPercap
#>   <chr>       <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Afghanistan Asia       1952    28.8  8425333      779.
#> 2 Afghanistan Asia       1957    30.3  9240934      821.
#> 3 Afghanistan Asia       1962    32.0 10267083      853.
#> 4 Afghanistan Asia       1967    34.0 11537966      836.
#> 5 Afghanistan Asia       1972    36.1 13079460      740.
#> 6 Afghanistan Asia       1977    38.4 14880372      786.
#> # … with 390 more rows
```

## Writing

You can write to a Google sheet using [`write_sheet()`](https://googlesheets4.tidyverse.org/reference/sheet_write.html). If the sheet already exists, any data on it will be overwritten.

## Finding sheets

It can sometimes be difficult to find the exact Google Sheet you're looking for. googlesheets4 includes a handy function that will return the names of the all your sheets, alongside their IDs, in an object called a _dribble_. A dribble is a tibble specifically for storing metadata about Google Drive files. 


```r
all_my_sheets <- gs4_find()
```




```r
all_my_sheets
#> # A dribble: 4 × 3
#>   name            id                                           drive_resource   
#>   <chr>           <drv_id>                                     <list>           
#> 1 top-secret-data 1_vlFSg_2zP9JXo_tj-Ct5EGqCYpp0RC74DZ-7eEybUA <named list [34]>
#> 2 important-data  1rOnvdsEmqhTVjPcvFUpLftL8jmaPdSaJJo-_tBA6udk <named list [34]>
#> 3 my-sheet-2      1aRknFvsCDiYzwPkhv-g59fjPcojzJD71jyZM2H0j-t8 <named list [34]>
#> 4 my-sheet-1      1vSUFy9ENZXfcKFOb0woYuoBQj5Jgabm4b_1YD55dKGI <named list [34]>
```

Note that `gs4_find()` will lists both sheets that you own and private sheets that you have access to. These are the same sheets that you can see on your [Google Sheets homepage](https://docs.google.com/spreadsheets/).

Now, you can easily search for a sheet by piping the results of `gs4_find()` into `view()`.


```r
all_my_sheets %>% 
  view()
```

## Authentication

### Interactive session

When you run R code in the console or in an R Markdown chunk, you're in an _interactive session_. R understands that it's interacting with a human, and so can prompt you for input or actions. In an interactive session, you don't need to worry much about authentication. googlesheets4 will do most of the work for you.

The first time you call a googlesheets4 function that requires authentication (e.g., `read_sheet(ss = id_gapminder)`), a browser tab will open and prompt you to sign into Google. Sign into your account and then return to RStudio. 

By default, your user credentials will now be stored as something called a gargle token. gargle is the name of an R package for working with Google APIs. The next time googlesheets4 requires authentication, it will use this token to authenticate you.

### Non-interactive session

When you knit an R Markdown, you're using R _non-interactively_. googlesheets4 can't prompt you to sign into Google, because it doesn't assume that there's a human standing by to do so. This should only be a problem if you're trying to knit an R Markdown document that uses googlesheets4 and you've never authenticated with googlesheets4 before. The easiest way to quickly authenticate and set up your gargle token is to run `googlesheets4::gs4_auth()` (you can run this anywhere: console, R Markdown chunk, etc.). Once you've signed into Google and returned to RStudio, try knitting your document. 

If you've authenticated with googlesheets4 before, but your R Markdown document never finishing knitting, you may need to update your gargle token. Run `googlesheets4::gs4_auth()` and then try knitting again.

<!--

### Remote scripts

If you're trying to run a script that uses googlesheets4 on a remote machine (like we explain [here](http://dcl-workflow.stanford.edu/rscripts-remote.html)), you'll need to do some more setup. 

Before running your script, open RStudio on the remote machine, then carry out the following steps:

__Step 1__ Run `gs4_auth()` to initialize your gargle token.  

__Step 2__ Open your .Rprofile in RStudio by running `usethis::edit_r_profile()`. 

__Step 3__ Add gargle options to your .Rprofile.

Paste the following into your .Rprofile, replacing `YOUR_GOOGLE_ACCOUNT_EMAIL` with your Google Account email (complete with the \@gmail.com, \@stanford.edu, etc.). 


```r
options(
  gargle_oauth_cache = "~/.R/gargle/gargle-oauth",
  gargle_oauth_email = "YOUR_GOOGLE_ACCOUNT_EMAIL"
)
```

Note that both need to be in quotes.

`"~/.R/gargle/gargle_oauth"` is the default location for the gargle token you initialized in Step 1. Now, instead of needing to prompt you for information, `gs4_auth()` can use the information stored in your .Rprofile options to authenticate you.

__Step 4__ Restart R for the changes to take effect. 

You can use the keyboard shortcut `Cmd/Ctrl + Shift + F10`, or go to _Session_ > _Restart R_. 

__Step 5__ Run `gs4_auth()` again.

Now, you're all set to run googlesheets4 on a remote machine. You may need to run `gs4_auth()` once per new R session (e.g., whenever you re-open RStudio, restart R, etc.).

-->
