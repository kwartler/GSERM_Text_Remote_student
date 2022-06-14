#' Title: Comparison Cloud
#' Purpose: Given two corpora find disjoint words and visualize
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 13, 2022
#'

# Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/B_Basic_Visuals/data")

# Options
options(scipen = 999)

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
  #corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'amp', 'chardonnay', 'beer')

# Read in multiple files as individuals
txtFiles <- list.files(pattern = 'beer|chardonnay')

for (i in 1:length(txtFiles)){
  assign(txtFiles[i], read.csv(txtFiles[i]))
  cat(paste('read completed:',txtFiles[i],'\n'))
}

# Vector Corpus; omit the meta data
beer       <- VCorpus(VectorSource(beer.csv$text))
chardonnay <- VCorpus(VectorSource(chardonnay.csv$text))

# Clean up the data
beer       <- cleanCorpus(beer, stops)
chardonnay <- cleanCorpus(chardonnay, stops)

# Another way to extract the cleaned text 
beer       <- unlist(pblapply(beer, content))
chardonnay <- unlist(pblapply(chardonnay, content))

# FYI
length(beer)

# Instead of 1000 individual documents, collapse each into a single "subject" ie a single document
beer       <- paste(beer, collapse = ' ')
chardonnay <- paste(chardonnay, collapse = ' ')

# FYI pt2
length(beer)
head(beer)

# Combine the subject documents into a corpus of *2* documents
allDrinks <- c(beer, chardonnay)
allDrinks <- VCorpus((VectorSource(allDrinks)))

# Make TDM with a different control parameter
# Tokenization `control=list(tokenize=bigramTokens)`
# You can have more than 1 ie `control=list(tokenize=bigramTokens, weighting = weightTfIdf)`
ctrl      <- list(weighting = weightTfIdf)
drinkTDM  <- TermDocumentMatrix(allDrinks, control = ctrl)
drinkTDMm <- as.matrix(drinkTDM)

# Make sure order is the same as the c(objA, objB) on line ~80
colnames(drinkTDMm) <- c('beer', 'chardonnay')

# Examine
head(drinkTDMm)

# Make comparison cloud
comparison.cloud(drinkTDMm, 
                 max.words=75, 
                 random.order=FALSE,
                 title.size=0.5,
                 colors=brewer.pal(ncol(drinkTDMm),"Dark2"),
                 scale=c(3,0.1))

# End