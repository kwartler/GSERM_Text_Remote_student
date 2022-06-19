#' Title: NLP HW 1
#' Purpose: 20pts...were you paying attention?
#' NAME: 
#' Date: Dec 29 2020

#### 1PT
# set your working directory
setwd("______")

# Load the following libraries ggplot2, ggthemes and tm
library(______)
library(______)
library(______)
library(stringi)

# load the homework data in an object called `text`
text <- read.csv("_____________")

#### 1PT
# 
# Examine the first 10 rows of data
head(_____, 10)

# Print the column names to console. HINT: function is names()
names(_____)

# What is the first tweet text? 
____$____[1]
# Answer:

# What are the dimension (number of rows and columns)? Use a function. Hint dim(),nrow(), ncol() could all help you
___(___)
# Answer:

#### 1PT
# Find out what rows have "virus" in the $text column in an object called idx
___ <- grep('____', ____$____, ignore.case = T)

# What is the length of idx?
______(___)
# Answer: 

# What is the tenth text mentioning "virus"
# hint: someObject$someColumnName[idx[someNumber]]
____$____[___[__]]

#### 1PT
# Use grepl to make idx again for 'virus'
___ <- ____('____', ______, ignore.case = T)

# Now what is the length of idx?

# Answer: 

# As a percent, how many tweets mention "virus" among all tweets?
___(___)/nrow(____)
# Answer: 

#### 5 PTs
# Write a function accepting a text column
# use gsub subsituting 'http\\S+\\s*' for '' which removes URLS
# use gsub substituting '(RT|via)((?:\\b\\W*@\\w+)+)' for '' which removes "RT" exactly
# use tolower in the function on the text
# return the changed text
basicSubs <- function(x){
  x <- gsub('______', '', _)
  _ <- gsub('______', '', _)
  _ <- tolower(_)
  return(x)
}

# apply the function to JUST THE TEXT COLUMN to  a new object txt
___ <- basicSubs(_________)

#### 3 PTs
# Use sum with stri_count on the newt txt object
# with "trump", "biden" and in the last one check for virus OR vaccine
trump  <- ___(stri_count(___, fixed ='_____'))
biden  <- sum(__________(___, fixed ='_____'))
vterms <- ___(__________(___, regex = '_____|_______'))

# Organize term objects into a data frame
termFreq <- data.frame(terms = c('trump','biden','vterms'),
                       freq  = c(_____,_____, ______))

# Examine
termFreq

# Plot it with ggplot2 by filling in the correct data, adding a layers "theme_gdocs() + theme(legend.position = "none")"
ggplot(________, aes(x = reorder(terms, freq), y = freq,fill=freq)) + 
  geom_bar(stat = "identity") + coord_flip() + 
  ___________() + _____(_______________ = "____")

#### 8 PTs
# Create some stopwords using the 'SMART' lexicon and add 'rofl'
stops <- c(stopwords('_____'), '____')

# Create a Clean Corpus Function
# add into the function removePunctuation
# add into the function removeNumbers
# add into the function stripWhitespace
cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url)) 
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  corpus <- tm_map(corpus, _________________)
  corpus <- tm_map(corpus, _____________)
  corpus <- tm_map(corpus, _______________)
  return(corpus)
}

# Apply the VCorpus Function to a VectorSource of the original text object
# Hint: only pass in the vector NOT the entire dataframe using a $
cleanTxt <- _______(____________(_________))

# Clean the Corpus with your function, this will take a few seconds
cleanTxt <- ___________(cleanTxt, stops)

# Construct a DTM
cleanDTM  <- __________________(cleanTxt)

# Switch this to a simple matrix 
cleanMat <- _________(cleanDTM)

# What are the dimensions of this matrix
___(cleanMat)

# What do rows represent in this matrix?
# Answer: 

# How many unique words exist in the matrix?
# Answer: 

# End