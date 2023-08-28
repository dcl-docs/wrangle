
# API basics


```r
library(tidyverse)
```




APIs, especially if you've never worked with them before, can be confusing. In this chapter, we'll try to demystify the process of working with APIs in R. You can use APIs for many different tasks, including reading in data, writing data (e.g., to Google Sheets), and carrying out tasks that you would usually carry out manually in your browser (e.g., pushing files to GitHub, moving files around in Google Drive, sending emails). We'll focus just on reading data, but many of the ideas explained here are also relevant to other tasks. 

## What is an API?

You're already used to sending and receiving information over the internet. When you navigate to a URL in your browser, you're requesting information. For example, if you open `http://twitter.com`, you're requesting that Twitter sends the information for its homepage over to your computer. Then, when you type out a tweet and click _Tweet_, you send information back over to Twitter.  

APIs work in much the same way. APIs allow you to send and receive information over the internet, and many even use URLs to control what information is sent or received. The main difference between using the internet "normally" and using an API is that the "normal" internet is made for humans, while APIs are made for computers. The Twitter homepage is designed so that it's easy for humans to read and send tweets, while the Twitter API is designed to make it easy for computers to download data and send tweets. 

You might think of using the internet normally like browsing a nicely lit, well-designed store, while using an API is like going directly to that store's highly organized warehouse. 

The type of API we're talking about here is actually called a _web API_. APIs (Application Programming Interfaces) are a much broader category that include all interfaces that facilitate communication between computer applications. However, when most people talk about APIs now, they mean web APIs. 

Next, we'll walk through the general steps of using an API, with the Census Bureau's API as an example. 

## Find your API

For the rest of this chapter, we'll use the [United States Census Bureau](https://www.census.gov/) as an example. The Census Bureau collects a large amount of data on the population of the United States and makes that data available through APIs.

The first step to using an API is to determine if one exists for the task you want to accomplish, and where it's documented. There are a couple ways to check if an organization supplies an API:

* Google _Name of organization_ + _API_. This is usually pretty effective.
* Look for a _Developers_ link on the organization homepage. This will often be at the bottom of the webpage, or under a _Data_ tab. 

Like many organizations, the Census Bureau stores information about its APIs under a [Developers page](https://www.census.gov/developers/). You can navigate to this page from the Census Bureau homepage by going to _Explore Data_ > _Developers_. Organizations often assume that developers are the ones using APIs (but you don't need to be a developer to use an API!). 

Once you've determined if an organization supplies APIs and where they document them, you need to determine which API you want. Many organizations will have multiple available APIs. Just like one organization (e.g., Google) can have multiple web applications (`drive.google.com`, `gmail.com`, `calendar.google.com`, etc.), organizations can have different APIs for different types of requests. 

The full list of Census Bureau APIs on its [Available APIs page](https://www.census.gov/data/developers/data-sets.html).

Browse the available APIs to determine which one you want (these are sometimes listed under _Endpoints_ or _Resources_ instead). For our Census example, we'll use the [Vintage 2018 Population Estimates API](https://www.census.gov/data/developers/data-sets/popest-popproj/popest.html), one of the many [Population Estimates and Projections APIs](https://www.census.gov/data/developers/data-sets/popest-popproj.html). Vintage 2018 sounds like it refers to a bottle of wine, but actually refers to estimates between 2018 and the 2010 Census.

Now that you've determined which API you to use, you're ready to start constructing your _API request_.

## Craft your request

The specifics of an API request determine the information you'll receive back. To figure out how to specify your request, you'll typically need to consult your API's documentation to determine two things:

* The base API request. This is analogous to a homepage URL, like https://www.wikipedia.org/.
* The API parameters. API parameters allow you to control what the request asks for, like how information at the end of a normal URL can point to a specific webpage (e.g., [https://en.wikipedia.org/wiki/Tardigrade](https://en.wikipedia.org/wiki/Tardigrade)).

### Base request

For APIs whose requests are URLs, the base request will usually look something like [api.[service-name].com/[other-details]](). For the Census Bureau API we're using, the base request is https://api.census.gov/data/2018/pep/population.

### Parameters

API parameters allow you to specify exactly what data you want. Figuring out API parameters is similar to figuring out function arguments. We need two pieces of information:

* What are the names of the parameters? 
* How do we specify the values of the parameters?

This is where the API documentation becomes especially important. Different organizations will document their APIs differently, but the documentation will typically include a table or list of the different parameters, as well as provide example requests. 

Let's look at one of the examples from the [Vintage 2018 API example page](https://api.census.gov/data/2018/pep/population/examples.html):

https://api.census.gov/data/2018/pep/population?get=GEONAME,POP&for=state:02&key=YOUR_KEY_GOES_HERE

The `?` marks the end of the base API request and the beginning of the parameters section. The `&`s separate the parameters from each other, just as commas separate function arguments in R. Finally, you supply values to parameters with `=`, just like in an R function call. 

The example request above has three parameters, all in lowercase: `get`, `for`, and `key`. We'll talk more about the Census APIs in the next chapter. For now, just know that the example supplies the value `GEONAME,POP` to `get` and `state:02` to `for`. 

`key` refers to an API access key. For some APIs, you'll need to request a key through their website and then include that key in your request. Other APIs, as you'll see in the [Google Sheets chapter](http://dcl-wrangle.stanford.edu/googlesheets.html), require a more complex form of authentication. However, the Census API doesn't require a key, so we'll remove that parameter:

https://api.census.gov/data/2018/pep/population?get=GEONAME,POP&for=state:02

`get` specifies which variables from the data we'll get back. The request says we want `GEONAME` (the name of the geography unit) and `POP` (population). `for` specifies the geographic unit. Here, we've said we want data for the state with the FIPS code `02`, which is Alaska. 

Now that we have an API request, we can test it out!

## Test your request

Our API request is a URL, so we can open it in the browser. Click on our example API request to see what it gives you:

https://api.census.gov/data/2018/pep/population?get=GEONAME,POP&for=state:02

You should see:


```
[["GEONAME","POP","state"],
["Alaska","737438","02"]]
```

Opening your request into the browser is a quick and easy way to check that you've gotten the request correct before reading the data into R. If you see a message saying "HTTP Status 404" or another error, your request probably has an error in it. 

In our example, our request was successful! We queried the Census Bureau's API and got back the population of Alaska for 2018. 

## Read the data into R

### JSON data

If the result of your API request looks like what we got above, the API is sending you data in JSON (JavaScript Object Notation). JSON is a common format for data from APIs. XML is another common format. If the data is in XML, you'll see a tag up at the top of the response that includes the word "xml". 

Here, we need a way to read JSON into R. We can use `fromJSON()` from the jsonlite package. 


```r
request <- "https://api.census.gov/data/2018/pep/population?get=GEONAME,POP&for=state:02"

jsonlite::fromJSON(request)
#>      [,1]      [,2]     [,3]   
#> [1,] "GEONAME" "POP"    "state"
#> [2,] "Alaska"  "737438" "02"
```

`jsonlite::fromJSON()` returns a matrix, not a tibble. We'll need to do some extra work to get the data into a tidy tibble. 


```r
request %>% 
  jsonlite::fromJSON() %>% 
  as_tibble() %>% 
  janitor::row_to_names(row_number = 1)
#> # A tibble: 1 × 3
#>   GEONAME POP    state
#>   <chr>   <chr>  <chr>
#> 1 Alaska  737438 02
```

`as_tibble()` converts the matrix to a tibble, and `janitor::row_to_names(row_number = 1)` converts the first row to the column names.

### All formats

The httr package provides a more general way of getting data from an API. We get use `httr::GET()` to send our request to an API and capture the response.


```r
response <- httr::GET(request)

response
#> Response [https://api.census.gov/data/2018/pep/population?get=GEONAME,POP&for=state:02]
#>   Date: 2021-09-10 20:21
#>   Status: 200
#>   Content-Type: application/json;charset=utf-8
#>   Size: 53 B
#> [["GEONAME","POP","state"],
```

The result is a response object, and contains additional information about the result of your request.


```r
class(response)
#> [1] "response"
```

httr contains functions for extracting information out of response objects. `httr::http_error()` returns `TRUE` if there was an error with your request, and `FALSE` otherwise.


```r
httr::http_error(response)
#> [1] FALSE
```

We can also determine the type of data with `httr::http_type()`.


```r
httr::http_type(response)
#> [1] "application/json"
```

It's JSON, which matches what we discovered in the previous section.

To extract out the actual data, we can use `httr::content()`.


```r
httr::content(response)
#> [[1]]
#> [[1]][[1]]
#> [1] "GEONAME"
#> 
#> [[1]][[2]]
#> [1] "POP"
#> 
#> [[1]][[3]]
#> [1] "state"
#> 
#> 
#> [[2]]
#> [[2]][[1]]
#> [1] "Alaska"
#> 
#> [[2]][[2]]
#> [1] "737438"
#> 
#> [[2]][[3]]
#> [1] "02"
```

Now, the data is a list. To turn into a tibble, we'll first turn it into a matrix.


```r
response %>% 
  httr::content() %>% 
  unlist() %>% 
  matrix(ncol = 3, byrow = TRUE)
#>      [,1]      [,2]     [,3]   
#> [1,] "GEONAME" "POP"    "state"
#> [2,] "Alaska"  "737438" "02"
```

`unlist()` turns the content into an atomic vector, and `matrix()` turns the vector into a matrix. `ncol` specifies that we want three columns, and `byrow = TRUE` causes `matrix()` to fill the matrix row-by-row, instead of column-by-column.

Then, we can apply the same steps as we did in the JSON section.


```r
response %>% 
  httr::content() %>% 
  unlist() %>% 
  matrix(ncol = 3, byrow = TRUE) %>% 
  as_tibble() %>% 
  janitor::row_to_names(row_number = 1)
#> # A tibble: 1 × 3
#>   GEONAME POP    state
#>   <chr>   <chr>  <chr>
#> 1 Alaska  737438 02
```

For our Census Bureau case (and many other situations), `jsonlite::fromJSON()` is an easier solution. However, it's useful to know about the httr package, especially if you're working with an API in a script or package. `httr::GET()` and `httr::http_error()` allow you to programmatically handle errors, while `jsonlite::fromJSON()` will fail if something goes wrong. 

httr also contains many other functions for working with APIs---we've just covered the basics. In addition to using `httr::GET()` to read in data, you can use functions like `httr::PUT()` and `httr::POST()` to _send_ data to APIs. You can read more about httr on the [package website](https://httr.r-lib.org/).

## Next steps

You now know the basics of working with APIs in R. Fortunately, there are R packages that wrap many of the commonly used APIs, hiding the messy details. If an R package is available, you won't have to worry about creating an API request yourself or figuring out how to read in the resulting data. In the coming chapters, we'll explain two such R packages: tidycensus and googlesheets4.

For the APIs without a matching R package, however, it's necessary to understand the workflow covered above. In the Census chapter, we'll go over additional examples of this workflow. 
