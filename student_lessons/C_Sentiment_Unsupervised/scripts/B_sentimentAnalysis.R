#' Title: Sentiment Analysis
#' Purpose: Inner join sentiment lexicons to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

# Wd
setwd('~/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data')

# Libs
library(tm)
library(lexicon)
library(tidytext)
library(dplyr)
library(qdap)
library(radarchart)

# Bring in our supporting functions
source('~/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Create custom stop words
stops <- c(stopwords('english'))

# Clean and Organize
txtDTM <- cleanMatrix('Weeknd.csv',
                      'text',
                      collapse        = F, 
                      customStopwords = stops, 
                      type            = 'DTM', 
                      wgt             = 'weightTf')

# Examine original & Compare

txtDTM[,1:10]
dim(txtDTM)

# Examine Tidy & Compare
# switch back to DTM because the convience function I wrote returns a matrix!!
# you can avoid this by not using the cleanMatrix function and instead coding it with cleanCorpus etc.
tmp      <- as.DocumentTermMatrix(txtDTM, weighting = weightTf ) 
tidyCorp <- tidy(tmp)
tidyCorp
dim(tidyCorp)

# Get bing lexicon
# "afinn", "bing", "nrc", "loughran"
bing <- get_sentiments(lexicon = c("bing"))
head(bing)

# Perform Inner Join
bingSent <- inner_join(tidyCorp, bing, by=c('term' = 'word'))
bingSent

# Quick Analysis
table(bingSent$sentiment, bingSent$count)
aggregate(count~sentiment,bingSent, sum)

# Compare original with qdap::Polarity
polarity(read.csv('Weeknd.csv')$text)
# avg. polarity  -0.409

# Get afinn lexicon
afinn<-get_sentiments(lexicon = c("afinn"))
head(afinn)

# Perform Inner Join
afinnSent <- inner_join(tidyCorp,afinn, by=c('term' = 'word'))
afinnSent

# Quick Analysis
weeknd <- read.csv('Weeknd.csv')$text
weekndWords <- data.frame(word = unlist(strsplit(weeknd,' ')))
weekndWords$word <- tolower(weekndWords$word )
weekndWords <- left_join(weekndWords,afinn, by=c('word' = 'word'))
weekndWords[is.na(weekndWords$value),2] <- 0
plot(weekndWords$value, type="l", main="Quick Timeline of Identified Words") 

# Get nrc lexicon; deprecated in tidytext, use library(lexicon)
nrc <- nrc_emotions
head(nrc)

# Clean this up
#nrc <- read.csv('nrcSentimentLexicon.csv')
#Use apply (rowwise) to find columns having value > 0
terms <- subset(nrc, rowSums(nrc[,2:9])!=0)
sent  <- apply(terms[,2:ncol(terms)], 1, function(x)which(x>0))
head(sent)

# Reshape
nrcLex <- list()
for(i in 1:length(sent)){
  x <- sent[[i]]
  x <- data.frame(term      = terms[i,1],
                  sentiment = names(sent[[i]]))
  nrcLex[[i]] <- x
}
nrcLex <- do.call(rbind, nrcLex)
head(nrcLex)

# Perform Inner Join
nrcSent <- inner_join(tidyCorp,nrcLex, by=c('term' = 'term'))
nrcSent

# Quick Analysis
table(nrcSent$sentiment)
emos <- data.frame(table(nrcSent$sentiment))
#emos <- emos[-c(6,7),] #drop columns if needed
chartJSRadar(scores = emos, labelSize = 10, showLegend = F)

# End