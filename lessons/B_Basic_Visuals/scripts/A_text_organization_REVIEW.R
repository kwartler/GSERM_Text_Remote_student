#' Title: Text Organization for Bag of Words
#' Purpose: Learn some basic cleaning functions & term frequency
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

# Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_admin/lessons/B_Basic_Visuals/data")

# Libs
library(tm)

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
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'smh')

# Data
text <- read.csv('coffee.csv', header=TRUE)

# As of tm version 0.7-3 tabular was deprecated
names(text)[1] <- 'doc_id' 

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Check Meta Data; brackets matter!!
txtCorpus[[4]]
meta(txtCorpus[4])
content(txtCorpus[[4]])

# Need to plain text cleaned copy?r
df <- data.frame(text = unlist(sapply(txtCorpus, `[`, "content")),
                 stringsAsFactors=F)
#write.csv(df,'plain_coffee.csv',row.names = F)

# Compare a single tweet
text$text[4]
df[4,]

# Make a Document Term Matrix or Term Document Matrix depending on analysis
txtDtm  <- DocumentTermMatrix(txtCorpus)
txtTdm  <- TermDocumentMatrix(txtCorpus)
txtDtmM <- as.matrix(txtDtm)
txtTdmM <- as.matrix(txtTdm)

# Examine
txtDtmM[610:611,491:493]
txtTdmM[491:493,610:611]

# Get the most frequent terms
topTermsA <- colSums(txtDtmM)
topTermsB <- rowSums(txtTdmM)

# Add the terms
topTermsA <- data.frame(terms = colnames(txtDtmM), freq = topTermsA)
topTermsB <- data.frame(terms = rownames(txtTdmM), freq = topTermsB)

# Remove row attributes
rownames(topTermsA) <- NULL
rownames(topTermsB) <- NULL

# Review
head(topTermsA)
head(topTermsB)

# Order
exampleReOrder <- topTermsA[order(topTermsA$freq, decreasing = T),]
head(exampleReOrder)

# Which term is the most frequent?
idx <- which.max(topTermsA$freq)
topTermsA[idx, ]

# End