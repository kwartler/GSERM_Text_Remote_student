#' Title: Intro: TidyText Sentiment
#' Purpose: Sentiment nonsense
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 14, 2022
#'

# Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/C_Sentiment_Unsupervised/data")

# Libs
library(tm)
library(tidytext)
library(dplyr)
library(qdap)
library(radarchart)
library(textdata)
library(ggplot2)

# Options & Functions
options(stringsAsFactors = FALSE)

# Custom Functions
tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus,customStopwords){
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}


# Data
text <- c(readLines('starboy.txt'), 
          readLines('in_your_eyes.txt'),
          readLines('pharrell_williams_happy.txt'))
cat(text)

docNames <- c("starboy", "eyes", "happy") 

# Create custom stop words
customStopwords <- c(stopwords('english'))

# Clean Corpus
txtCorpus <- VCorpus(VectorSource(text))
txtCorpus <- cleanCorpus(txtCorpus, customStopwords)

# DTM
txtDTM    <- DocumentTermMatrix(txtCorpus)
txtDTM
dim(txtDTM)

# Tidy
tidyCorp <- tidy(txtDTM)
tidyCorp
dim(tidyCorp)

# Get bing lexicon
# "afinn", "bing", "nrc", "loughran"
bing <- get_sentiments(lexicon = c("bing"))
head(bing)

# Perform Inner Join
bingSent <- inner_join(tidyCorp,bing, by=c('term'='word'))
bingSent

# Quick Analysis - count of words
bingAgg <- aggregate(count~document+sentiment, bingSent, sum)
reshape2::dcast(bingAgg, document~sentiment)

# Compare with qdap::Polarity
qdap::polarity(text[1])
qdap::polarity(text[2])
qdap::polarity(text[3])

# End