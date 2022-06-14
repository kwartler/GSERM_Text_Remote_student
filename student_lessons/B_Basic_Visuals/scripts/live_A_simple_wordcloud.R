#' Title: Simple wordcloud 
#' Purpose: Live wordcloud step through of win reviews
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 13, 2022
#' 

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/B_Basic_Visuals/data")

# Libs
library(tm)
library(qdap) # Comment out if you have qdap problems
library(wordcloud)
library(RColorBrewer)

# this is 130K rows, so you can read in a small amount if you want
n <- 1000

# bring in the data
wineReviews <- read.csv(unz("wineReviewData.zip", 
                            "winemag-data-130k-v2.csv"), nrows=n)
#wineReviews <- read.csv(unz("wineReviewData.zip", 
#                            "winemag-data-130k-v2.csv"))

# Explore it so we know what is it
names(wineReviews)
head(wineReviews)

# As part of EDA you may want to understand variety
table(wineReviews$variety)

# Or plot the country
barplot(table(wineReviews$country), las = 2)

# What about some summary stats for points and price?
summary(wineReviews$points)
summary(wineReviews$price)

# Is there an interaction between the two?
plot(wineReviews$points,wineReviews$price)
cor(wineReviews$points,wineReviews$price, use = 'complete.obs')

# Lets get the most frequent terms in the description field
wineDescriptions <- wineReviews$description

# Custom Functions
tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  #corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'wine')

# Make a volatile corpus
txtCorpus <- VCorpus(VectorSource(wineDescriptions))

# Clean the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Make bi-gram TDM according to the tokenize control & convert it to matrix
wineTDM  <- TermDocumentMatrix(txtCorpus) # if complete data: 44186 terms 129900 wines
wineTDMm <- as.matrix(wineTDM)

# How many unique words?
dim(wineTDMm)

# Get Row Sums & organize
wineTDMv <- sort(rowSums(wineTDMm), decreasing = TRUE)
wineDF   <- data.frame(word = names(wineTDMv), freq = wineTDMv, row.names = NULL)

# Let's make our wordcloud
wordcloud(wineDF$word,
          wineDF$freq,
          max.words    = 100,
          random.order = F,
          colors       = c('grey', 'goldenrod', 'tomato'),
          scale        = c(2,1))

# QDAP Quick and dirty; less customization i.e. bigrams and preprocessing
wineWFM <- wfm(wineDescriptions, stopwords = stops)
wordcloud(rownames(wineWFM),
          wineWFM[,1],
          max.words = 100,
          random.order = F,
          colors       = c('grey', 'goldenrod', 'tomato'),
          scale        = c(2,1))


# End