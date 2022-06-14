#' Title: Dendrograms and Word Networks
#' Purpose: Use text for various HC and network visuals
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
library(ggplot2)
library(ggthemes)
#library(ggdendrogram)

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
stops <- c(stopwords('SMART'), 'amp', 'britishairways', 'british',
           'flight', 'flights', 'airways')

# Read in Data, clean & organize
text      <- read.csv('BritishAirways.csv')
txtCorpus <- VCorpus(VectorSource(text$text))
txtCorpus <- cleanCorpus(txtCorpus, stops)
tweetTDM  <- TermDocumentMatrix(txtCorpus)

# Reduce TDM
reducedTDM <- removeSparseTerms(tweetTDM, sparse=0.985) #shoot for ~50 terms; 1.5% of cells in row have a value  
reducedTDM

# Organize the smaller TDM
reducedTDM <- as.data.frame(as.matrix(reducedTDM))

# Basic Hierarchical Clustering
hc <- hclust(dist(reducedTDM))
plot(hc,yaxt='n')

#ggdendro::ggdendrogram(hc, rotate=FALSE) # unable to load bc package is not updated

############ Back to PPT

networkStops <- c(stops, 'britishairways', 'british', 'airways', 'rt')

assocText <- rm_url(text$text)

# MORE QDAP!
word_associate(assocText, 
               match.string = 'brewdog', 
               stopwords = networkStops,
               network.plot = T,
               cloud.colors = c('black','darkred'))

# MORE QDAP!
word_associate(assocText, 
               match.string = 'brewdog', 
               stopwords = networkStops,
               wordcloud = T,
               cloud.colors = c('black','darkred'))

# End

