#' Title: Sentiment Analysis
#' Purpose: Inner join sentiment lexicons to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 15, 2021
#'

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/C_Sentiment_Unsupervised/data")

# Libs
library(tm)
library(lexicon)
library(tidytext)
library(dplyr)
library(qdap)
library(radarchart)
library(tidyr)

# Bring in our supporting functions
source('~/Desktop/GSERM_Text_Remote_student/student_lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

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
# switch back to DTM because the function I wrote returns a matrix!!
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

# Pivot the data for joining
nrcLex <- pivot_longer(nrc, c(-term))
nrcLex <- subset(nrcLex, nrcLex$value>0)
head(nrcLex)
nrcLex$value <- NULL

# Perform Inner Join
nrcSent <- inner_join(tidyCorp,nrcLex, by=c('term' = 'term'))
nrcSent

# Quick Analysis
table(nrcSent$name)
emos <- data.frame(table(nrcSent$name))
chartJSRadar(scores = emos, labelSize = 10, showLegend = F)

# End