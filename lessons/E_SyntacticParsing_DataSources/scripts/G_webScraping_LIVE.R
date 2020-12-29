#' Title: Webscraping a single page
#' Purpose: Scrape a single page example
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

#### Reminder restart R because of readxl conflicts

# libraries
library(rvest)

# Get the webpage
movieURL <- 'https://www.imdb.com/title/tt0058331'
movie <- read_html(movieURL)
movie

# Numeric info
rating <- movie %>% 
  html_nodes("strong span") %>%
  html_text() %>%
  as.numeric()
rating

# Get the cast names
cast <- movie %>%
  html_nodes("#titleCast") %>% 
  html_nodes("tr") %>%
  html_text()
cast

# Webscraping is messy!
cast  <- gsub("[\r\n]", "", cast)
cast  <- lapply(cast, trimws)
cast  <- unlist(cast)
cast2 <- strsplit(cast, '[...]')
part  <- lapply(cast2, tail, 1) %>% unlist() %>% trimws()
actor <- lapply(cast2, head, 1) %>% unlist() %>% trimws()

df <- data.frame(part, actor)
df <- df[-1,]
df

# What is the URL for the movie poster?
poster <- movie %>%
  html_nodes(".poster img") %>%
  html_attr("src")
poster

# Storyline
storyline <- movie %>%
  html_nodes('#titleStoryLine') %>%
  html_text() 
storyline <- gsub("[\r\n]", "", storyline)
storyline <- strsplit(storyline, 'Written by')[[1]][1]
storyline

# More mess!
movieGross <- movie %>%
  html_nodes('#titleDetails') %>% html_text()
movieGross

movieGross <- strsplit(movieGross, 'Cumulative Worldwide Gross')[[1]][2]
movieGross <- substr(movieGross, 3,14)
movieGross
movieGross <- as.numeric(gsub('[$]|,','', movieGross))
movieGross

# End