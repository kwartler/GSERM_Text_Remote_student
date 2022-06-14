#' Title: D3 Word cloud
#' Purpose: Make a d3 wordcloud webpage
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
library(wordcloud2)
library(RColorBrewer)

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
stops <- c(stopwords('english'), 'lol', 'amp', 'chardonnay')

# Bigram token maker
bigramTokens <-function(x){
  unlist(lapply(NLP::ngrams(words(x), 2), paste, collapse = " "), 
         use.names = FALSE)
}

# Data
text <- read.csv('chardonnay.csv', header=TRUE)

# As of tm version 0.7-3 tabular was deprecated
names(text)[1]<-'doc_id' 

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Make bi-gram TDM according to the tokenize control & convert it to matrix
wineTDM  <- TermDocumentMatrix(txtCorpus, 
                               control=list(tokenize=bigramTokens))
wineTDMm <- as.matrix(wineTDM)

# See a bi-gram
exampleTweet <- grep('wine country', rownames(wineTDMm))
wineTDMm[(exampleTweet-2):(exampleTweet),870:871]

# Get Row Sums & organize
wineTDMv <- sort(rowSums(wineTDMm), decreasing = TRUE)
wineDF   <- data.frame(word = names(wineTDMv), freq = wineTDMv)

# Regular dynamic WC, click the pop-out in the viewer
wordcloud2(data = wineDF[1:50,])
?wordcloud2

# Choose a color & drop light ones
pal <- brewer.pal(8, "Dark2")
wordcloud2(wineDF[1:50,], 
           color = pal, 
           backgroundColor = "lightgrey")

# Some built in shapes need to click "show in new window"
# 'circle', 'cardioid', 'diamond', 'triangle-forward', 'triangle', 'pentagon', & 'star'
wordcloud2(wineDF[1:50,],
           shape = "cardioid",
           color = "blue",
           backgroundColor = "pink")

# Lettercloud and file mask functions do not work w/Chrome therefore not covered.The package is basically orphaned at this point :(
# https://github.com/Lchiffon/wordcloud2/issues/12
#letterCloud(wineDF, word = "wine", wordSize = 1)
#figPath = system.file("examples/t.png",package = "wordcloud2")
#wordcloud2(wineDF, figPath = figPath, size = 1.5,color = "skyblue")

# End