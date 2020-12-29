#' Title: GSERM REMOTE DAY 2 HW
#' Purpose: 20pts...where you paying attention?
#' NAME: 
#' Date: Dec 29 2020

#### 5PTs
# set your working directory
setwd("________")

# Load the following libraries ggplot2, ggthemes, tm & wordcloud
library(________)
library(________)
library(________)
library(________)

# Options & Functions; just leave it alone :)
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# load the homework data, beer.csv, in an object called `text`
text <- read.csv("______")

# Standard tryTolower, just leave it alone
tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

# Create the "cleanCorpus" function used in other scripts with
# rm_url, removeNumbers, removePunctuation, stripWhitespace,
# tryTolower, removeWords
cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::_____))
  corpus <- tm_map(corpus, _________________)
  corpus <- tm_map(corpus, _________________)
  corpus <- tm_map(corpus, _________________)
  corpus <- tm_map(corpus, content_transformer(________))
  corpus <- tm_map(corpus, ____________, customStopwords)
  return(corpus)
}

# Create custom stop words with the 'english' lexicon, 'amp' and 'beer'
stops <- c(stopwords('english'),"","")

# Make a volatile corpus with a VectorSource only on the text column
txtCorpus <- ___________(__________(__________$______))

# Preprocess the corpus using cleanCorpus
txtCorpus <- _________(________, _____)

# Make a Document Term Matrix from the corpus, then change to a matrix
beerDTM  <- ____________(_______)
beerDTMm <- as.matrix(beerDTM)

# Create a word frequency matrix called `beerWFM`
# Hint: be sure to use the right colSums or rowSums based on the DTM/TDM
_______ <- data.frame(term = names(______(beerDTMm)),
                      freq = ______(beerDTMm))

# Examine the 6 first rows to make sure you made it correctly.
____(_______)

# Order the WFM & remove the row names
beerWFM <- beerWFM[_____(beerWFM$____),]
rownames(______) <- ____

# Find the most frequent 6 terms, this can be tricky bc of the order function above.
____(beerWFM)

#### 5PTs
# Find the terms associated with "coffee" at 0.25
coffeeTerms <- _______(beerDTM, '_____', ___)

# Organize the association data, go back and review how to construct this because coffeeTerms is a list so its a bit funky.
coffeeTerms <- data.frame(terms=names(_________[[1]]),
                          value=______(________))

# Just a utility to make the ggplot nicer, leave this alone
coffeeTerms$terms <- factor(coffeeTerms$terms, 
                        levels=coffeeTerms$terms)
rownames(coffeeTerms) <- NULL

# Build a dot plot using the coffeeTerms Object
# y should be terms
# add a geom_point layer with x = value and coffeeTerms as data
# add a theme using fivethirtyeight colors
ggplot(______, aes(y = _____)) +
  __________(aes(x = _____), data = ___________, col = '#c00c00') +
  ________________() + 
  geom_text(aes(x = value, label = value), 
            colour = "red", hjust = "inward", 
            vjust = "inward" , size= 3) 

#### 5PTs
# Make a barplot using ggplot2 of the top 30 terms, make sure bars are ordered from most frequent to least

# Subset the WFM so you have ~30 terms in the topWords object
topWords      <- subset(beerWFM, beerWFM$freq >= __) 

# Change topWords to a factor, just leave this alone.
topWords$term <- factor(topWords$term, 
                        levels=unique(as.character(topWords$term))) 

# Create a bar plot
# add  theme_tufte() 
ggplot(topWords, aes(x = term, y = freq)) + 
  _______(stat="identity", fill='darkred') + 
  coord_flip() + __________() +
  geom_text(aes(label = freq), colour = "white", 
            hjust = 1.25, size = 3.0)

#### 5PTs
# Construct a simple wordcloud with 
# maximum words equal to 100
# c('#c0c0c0', '#bada55', '#10aded')
wordcloud(beerWFM$____,
          beerWFM$____,
          colors = c('#c0c0c0', '#bada55', '#10aded'),
          ________ = ___)

# End