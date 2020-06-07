#' Title: GSERM REMOTE DAY 1 HW
#' Purpose: 20pts...where you paying attention?
#' NAME: 
#' Date: May 23-2020

#### 1PT
# set your working directory
setwd("______")

# Load the following libraries ggplot2, ggthemes and tm
library(______)
library(______)
library(______)

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
# Find out what rows have "Kobe" in the $text column in an object called idx
___ <- grep('____', ____$____, ignore.case = T)

# What is the length of idx?
______(___)
# Answer: 

# What is the tenth text mentioning "Kobe"
# hint: someObject$someColumnName[idx[someNumber]]
____$____[___[__]]

#### 1PT
# Use grepl to make idx again for 'Kobe'
___ <- ____('____', ______, ignore.case = T)

# Now what is the length of idx?

# Answer: 

# As a percent, how many tweets mention "Kobe" among all tweets?
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
# Use table() to count the number of teams in the original data set in teamFreq HINT: Refer to the "team" column in the "text" object
_______ <- ____(______$_______)

# Convert it to a dataframe by ovrewriting the object
teamFreq <- as.data.frame(______)

# Examine
teamFreq

# Order the DF by frequency
teamFreq <- teamFreq[order(________$Freq),]

# Examine & note the new order
teamFreq

# Plot it with ggplot2 by filling in the correct data, adding a layers "theme_gdocs() + theme(legend.position = "none")"
ggplot(________, aes(x = reorder(Var1, Freq), y = Freq,fill=Freq)) + 
  geom_bar(stat = "identity") + coord_flip() + 
  __________() + _____(_________ = "none")

#### 8 PTs
# Create some stopwords using the 'SMART' lexicon and add 'rofl'
stops <- c(stopwords('_____'), '_____')

# Create a Clean Corpus Function
# add into the function removePunctuation
# add into the function stripWhitespace
# add into the function removeNumbers
cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url)) 
  corpus <- tm_map(corpus, _______________)
  corpus <- tm_map(corpus, _______________)
  corpus <- tm_map(corpus, _______________)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Apply the VCorpus Function to a VectorSource
# Hint: only pass in the vector NOT the entire dataframe
cleanTxt <- VCorpus(VectorSource(____$____))

# Clean the Corpus with your function, this will take a few seconds
cleanTxt <- cleanCorpus(______, ____)

# Construct a DTM
cleanDTM  <- _________________(cleanTxt)

# Switch this to a simple matrix 
cleanMat <- as.matrix(______)

# What are the dimensions of this matrix
___(cleanMat)

# What do rows represent in this matrix?
# Answer: 

# How many unique words exist in the matrix?
# Answer: 

# End