#' Title: Intro: TidyText Sentiment
#' Purpose: Tody radar chart
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 14, 2022
#'
#'# Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/C_Sentiment_Unsupervised/data")

# Libs
library(tm)
library(tidytext)
library(dplyr)
library(textdata)

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url)) 
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'smh')

# Data
text <- read.csv('coffee.csv', header=TRUE)

# As of tm version 0.7-3 tabular was deprecated
names(text)[1] <- 'doc_id' 

# Order by created date
text <- text[order(as.POSIXct(text$created)),]

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# DTM and Tidy
coffeeCorpus <- DocumentTermMatrix(txtCorpus)
coffeeCorpus <- tidy(coffeeCorpus)

# Get the AFINN lexicon
pth <- list.files(pattern    = 'afinn.csv',
                  full.names = T,
                  recursive  = T)
afinn <- read.csv(pth)
head(afinn)

# Join
coffeeAfinn <- inner_join(coffeeCorpus, afinn, by = c('term' = 'word'))
coffeeAfinnAgg <- aggregate(value ~ document, coffeeAfinn, sum)

# Quick timeline, but of course with timestamps you could make a real "time series" object
coffeeAfinnAgg$document <- as.numeric(as.character(coffeeAfinnAgg$document))
coffeeAfinnAgg <- coffeeAfinnAgg[order(coffeeAfinnAgg$document),]
plot(coffeeAfinnAgg$value, type = 'l')
plot(TTR::SMA(coffeeAfinnAgg$value,10), type = 'l')


# Get nrc lexicon, again causes probs on rstudio cloud
nrc <- textdata::lexicon_nrc() # should download it
head(nrc)

# Perform Inner Join
nrcSent <- inner_join(coffeeCorpus,nrc, by=c('term' = 'word'))
nrcSent

# Drop pos/neg leaving only emotion
nrcSent <- nrcSent[-grep('positive|negative',nrcSent$sentiment),]

# Manipulate for radarchart
nrcSentRadar <- as.data.frame(table(nrcSent$sentiment))
nrcSentRadar

# Normalize for length; prop.table needs a "matrix" class...annoying!
nrcProportions <- prop.table(as.matrix(nrcSentRadar[,2]),2)
nrcProportions
colSums(nrcProportions)

# Organize
nrcSentRadar <- data.frame(nrcSentRadar,
                           nrcProportions)
nrcSentRadar

# Chart raw freq
chartJSRadar(scores = nrcSentRadar[,c(1,2)], labelSize = 10, showLegend = T)

# Chart proportional
chartJSRadar(scores = nrcSentRadar[,c(1,3)], labelSize = 10, showLegend = T)
# End