#' Title: Commonality Cloud
#' Purpose: Given two corpora find words in common and visualize
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 13, 2022
#'

# Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/B_Basic_Visuals/data")

# Libs
library(tm)
library(qdap)
library(wordcloud)
library(RColorBrewer)
library(pbapply)

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
  corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'amp', 'chardonnay', 'coffee')

# Read in multiple files as individuals
txtFiles <- list.files(pattern = 'chardonnay|coffee')

for (i in 1:length(txtFiles)){
  assign(txtFiles[i], read.csv(txtFiles[i]))
  cat(paste('read completed:',txtFiles[i],'\n'))
}

# Vector Corpus; omit the meta data
chardonnay <- VCorpus(VectorSource(chardonnay.csv$text))
coffee     <- VCorpus(VectorSource(coffee.csv$text))

# Clean up the data
chardonnay <- cleanCorpus(chardonnay, stops)
coffee     <- cleanCorpus(coffee, stops)

# Another way to extract the cleaned text 
chardonnay <- unlist(pblapply(chardonnay, content))
coffee     <- unlist(pblapply(coffee, content))

# FYI
length(chardonnay)

# Instead of 1000 individual documents, collapse each into a single "subject" ie a single document
chardonnay <- paste(chardonnay, collapse = ' ')
coffee     <- paste(coffee, collapse = ' ')

# FYI pt2
length(chardonnay)

# Combine the subject documents into a corpus of *2* documents
allDrinks <- c(chardonnay, coffee)
allDrinks <- VCorpus((VectorSource(allDrinks)))

# How many docs now?
allDrinks

# Make TDM
drinkTDM  <- TermDocumentMatrix(allDrinks)
drinkTDMm <- as.matrix(drinkTDM)

# Make sure order is correct!
colnames(drinkTDMm) <- c('chardonnay', 'coffee')

# Examine
head(drinkTDMm)


commonality.cloud(drinkTDMm, 
                  max.words=150, 
                  random.order=FALSE,
                  colors='blue',
                  scale=c(3.5,0.25))


# End