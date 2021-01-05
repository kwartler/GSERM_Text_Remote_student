#' Title: Comparison Cloud Bank Loan
#' Purpose: Loan Comparison CLoud; Use bigrams to ID words for good/bad loans
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

# Set the working directory
setwd("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/B_Basic_Visuals/data")

# Libs
library(tm)
library(wordcloud)

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

bigramTokens <-function(x){
  unlist(lapply(NLP::ngrams(words(x), 2), paste, collapse = " "), 
         use.names = FALSE)
}


# Create custom stop words
stops <- c(stopwords('english'), 'loan', 'debt')

# Data
df <- read.csv('20K_sampleLoans.csv')
df$purpose <- gsub('_', ' ', df$purpose)

# smaller for tm work
txtOutcome <- data.frame(doc_id = seq_along(df$purpose),
                         text   = df$purpose,
                         y      = df$y)

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(txtOutcome))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# After cleaning split
head(meta(txtCorpus))
goodLoans <- subset(txtCorpus, meta(txtCorpus)==1)
badLoans  <- subset(txtCorpus, meta(txtCorpus)==0)

# Extract the clean txt & collapse 
goodLoans <- unlist(lapply(goodLoans, content))
goodLoans <- paste(goodLoans, collapse = ' ')

badLoans <- unlist(lapply(badLoans, content))
badLoans <- paste(badLoans, collapse = ' ')

# Combine & create corpus
bothOutcomes <- c(goodLoans, badLoans)
bothOutcomes <- VCorpus(VectorSource(bothOutcomes))

# Make TDM
bothTDM <- TermDocumentMatrix(bothOutcomes)#, 
#control = list(tokenize  = bigramTokens))
bothTDM <- as.matrix(bothTDM)

colnames(bothTDM) <- c('good', 'bad')

comparison.cloud(bothTDM, 
                 max.words    = 15, 
                 random.order = FALSE,
                 title.size   = 1.75,
                 colors       = c('#bada55', 'blue'))#,scale=c(3,1))


table(df$purpose, df$y)
prop.table(table(df$purpose, df$y), 1)
# End