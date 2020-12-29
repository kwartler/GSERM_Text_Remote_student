#' Title: GSERM REMOTE DAY 2 HW
#' Purpose: 20pts...where you paying attention?
#' NAME: 
#' Date: Dec 29 2020

#### 5PTs
# set your working directory
setwd("~/Desktop/GSERM_Text_Remote_admin/lessons/B_Basic_Visuals/HW")

# Load the following libraries ggplot2, ggthemes, tm & wordcloud
library(ggplot2)
library(ggthemes)
library(tm)
library(wordcloud)

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# load the homework data in an object called `text`
text <- read.csv("beer.csv")

# Create the "tryToLower" function used in other scripts
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
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words with 'english' lexicon, 'amp' and 'beer'
stops <- c(stopwords('english'), 'amp', 'beer')

# Make a volatile corpus with a VectorSource
txtCorpus <- VCorpus(VectorSource(text$text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Make a Document Term Matrix
beerDTM  <- DocumentTermMatrix(txtCorpus)
beerDTMm <- as.matrix(beerDTM)

# Create a word frequency matrix
beerWFM <- data.frame(term = names(colSums(beerDTMm)),
                      freq = colSums(beerDTMm))

# Examine the 6 first rows to make sure you made it correctly.
head(beerWFM)

# Order the WFM & remove the row names
beerWFM <- beerWFM[order(beerWFM$freq),]
rownames(beerWFM) <- NULL

# Find the most frequent 6 terms
tail(beerWFM)

#### 5PTs
# Find the terms associated with "coffee" at 0.25
coffeeTerms <- findAssocs(beerDTM, 'coffee', 0.25)

# Organize the association data
coffeeTerms <- data.frame(terms=names(coffeeTerms[[1]]),
                      value=unlist(coffeeTerms))
coffeeTerms$terms <- factor(coffeeTerms$terms, 
                        levels=coffeeTerms$terms)
rownames(coffeeTerms) <- NULL

# Build a dot plot using the coffeeTerms Object & ggplot2
ggplot(coffeeTerms, aes(y = terms)) +
  geom_point(aes(x = value), data = coffeeTerms, col = '#c00c00') +
  theme_fivethirtyeight() + 
  geom_text(aes(x = value, label = value), 
            colour = "red", hjust = "inward", 
            vjust = "inward" , size= 3) 

#### 5PTs
# Make a barplot using ggplot2 of the top 30 terms, make sure bars are ordered from most frequent to least

# Subset the WFM so you have 30 terms in the topWords object
topWords      <- subset(beerWFM, beerWFM$freq >= 75) 

# Change topWords to a factor 
topWords$term <- factor(topWords$term, 
                        levels=unique(as.character(topWords$term))) 

# Create the bar plot
ggplot(topWords, aes(x = term, y = freq)) + 
  geom_bar(stat="identity", fill='darkred') + 
  coord_flip()+ theme_tufte()  +
  geom_text(aes(label = freq), colour = "white", 
            hjust = 1.25, size = 3.0)

#### 5PTs
# Construct a simple wordcloud with 
# maximum words equal to 100
# c('#c0c0c0', '#bada55', '#10aded')
wordcloud(beerWFM$term,
          beerWFM$freq,
          colors = c('#c0c0c0', '#bada55', '#10aded'),
          max.words = 100)

# End