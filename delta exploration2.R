library(curl)
library(xml2)
library(httr)
library(rvest)
library(stringi)



library(httr)
ck <- handle_cookies(handle_find("https://marketplace.delta.com/merch/ui/v1/index.html")$handle)
ck


x <- httr::GET(url = "https://marketplace.delta.com/merch/api/search.json?onSale=true&pageNumber=1&pageSize=100&view=grid",
               accept_json(),
               add_headers(cookie="JSESSIONID=EB83BA05ABD55003EB02199DCD82F716")
)                                             
x$status_code

z <- content(x, "parsed")
z$searchResult
z$marketPlaceIncluded
z$totalProducts


# warm up the curl handle
start <- GET("https://marketplace.delta.com/merch/api/search.json?onSale=true&pageNumber=1&pageSize=100&view=grid")

# get the cookies


x <- httr::GET(url = "https://marketplace.delta.com/merch/api/search.json?onSale=true&pageNumber=1&pageSize=100&view=grid",
               accept_json(),
               user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:40.0) Gecko/20100101 Firefox/40.0")
               add_headers(cookie=ck$name[2])
)



doc <- read_html(content(res, as="text"))