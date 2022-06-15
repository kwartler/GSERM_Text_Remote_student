#' Title: Topic Modeling 
#' Purpose: Unsupervised LDA model building
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 15, 2021
#'
#'FOR REALLY DECENT EXPLANATION w/more math http://i.amcat.nl/lda/understanding_alpha.html

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/C_Sentiment_Unsupervised/data")

# Libs
library(tm)
library(qdap)
library(pbapply)
library(lda)
library(LDAvis)
library(dplyr)
library(treemap)

# Bring in our supporting functions
source('~/Desktop/GSERM_Text_Remote_student/student_lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# In some cases, blank documents and words are created bc of preprocessing.  This will remove them.
blankRemoval<-function(x){
  x <- unlist(strsplit(x,' '))
  x <- subset(x,nchar(x)>0)
  x <- paste(x,collapse=' ')
}

# Each term is assigned to a topic, so this will tally for a document & assign the most frequent as membership
docAssignment<-function(x){
  x <- table(x) 
  x <- as.matrix(x)
  x <- t(x)
  idx <-max.col(x)
  x <- as.numeric(names(x[1,idx]))
  return(x)
}

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Stopwords
stops <- c(stopwords('SMART'), 'pakistan', 'gmt', 'pm')

# Data articles from ~2016-04-04
text <- readRDS("Guardian_text.rds")
text$body[1]

# String clean up 
text$body <- iconv(text$body, "latin1", "ASCII", sub="")
text$body <- gsub('http\\S+\\s*', '', text$body ) #rm URLs; qdap has rm_url same outcome. 
text$body <- bracketX(text$body , bracket="all") #rm strings in between parentheses, and other brackets
text$body <- replace_abbreviation(text$body ) # replaces a.m. to AM etc
text$body[1]

# Instead of DTM/TDM, just clean the vector w/old functions
txt <- VCorpus(VectorSource(text$body))
txt <- cleanCorpus(txt, stops)

# Extract the clean text
txt <- unlist(pblapply(txt, content))

# Remove any blanks, happens sometimes w/tweets bc small length & stopwords
txt <- pblapply(txt, blankRemoval)

# Lexicalize
txtLex <- lexicalize(txt)

# Examine the vocab or key and value pairing between key ()
head(txtLex$vocab, 15) # rememnber #6
length(txtLex$vocab) #8k+ unique words among all articles, each 
head(txtLex$documents[[1]][,1:15]) #look at [,6] & [,10]
head(txtLex$documents[[20]])

# Corpus stats
txtWordCount  <- word.counts(txtLex$documents, txtLex$vocab)
txtDocLength  <- document.lengths(txtLex$documents)

# LDA Topic Modeling
# suppose you have a bag of dice (documents)
# alpha - there is a distribution of the probabilities of how similar they are to each other, are dice similar in size/shape/weight?
# eta   - there is also a distribution of probabilities for the number of topics inside a single document, are dice 6 sided or other?
# 
k       <- 5 # number of topics
numIter <- 25 # number of reviews, it performs random word sampling each time
alpha   <- 0.02 #see above 
eta     <- 0.02 #see above
set.seed(1234) 
fit <- lda.collapsed.gibbs.sampler(documents      = txtLex$documents, 
                                   K              = k, 
                                   vocab          = txtLex$vocab, 
                                   num.iterations = numIter, 
                                   alpha          = alpha, 
                                   eta            = eta, 
                                   initial        = NULL, 
                                   burnin         = 0,
                                   compute.log.likelihood = TRUE)

# Prototypical Document
top.topic.documents(fit$document_sums,2) #top 2 docs (rows) * topics(cols)

# explore some of the results
fit$document_sums #topics by articles
head(t(fit$topics)) #words by topics

# LDAvis params
# normalize the article probabilities to each topic
theta <- t(pbapply(fit$document_sums + alpha, 2, function(x) x/sum(x))) # topic probabilities within a doc will sum to 1

# normalize each topic word's impact to the topic
phi  <- t(pbapply(fit$topics + eta, 1, function(x) x/sum(x)))

ldaJSON <- createJSON(phi = phi,
                      theta = theta, 
                      doc.length = txtDocLength, 
                      vocab = txtLex$vocab, 
                      term.frequency = as.vector(txtWordCount))

serVis(ldaJSON)

# Topic Extraction
top.topic.words(fit$topics, 5, by.score=TRUE)

# Name Topics
topFive <- top.topic.words(fit$topics, 5, by.score=TRUE)
topFive <- apply(topFive,2,paste, collapse='_') #collapse each of the single topics word into a single "name"

# Topic fit for first 10 words of 2nd doc
fit$assignments[[2]][1:10]

# Tally the topic assignment for the second doc, which topic should we assign it to?
table(fit$assignments[[2]])

# What topic is article 2 assigned to?
singleArticle <- docAssignment(fit$assignments[[2]])

# Get numeric assignments for all docs
topicAssignments <- unlist(pblapply(fit$assignments,
                                    docAssignment))
topicAssignments

# Recode to the top words for the topics; instead of topic "1", "2" use the top words identified earlier
length(topicAssignments)
assignments <- recode(topicAssignments,
                      `0` = topFive[1], 
                      `1` = topFive[2], 
                      `2` = topFive[3], 
                      `3` = topFive[4], 
                      `4` = topFive[5])

# Polarity calc to add to visual
txtPolarity <- polarity(txt)[[1]][3]
#saveRDS(txtPolarity, 'txtPolarity.rds')
txtPolarity <- readRDS('txtPolarity.rds')

# Final Organization
allTree <- data.frame(topic    = assignments, 
                      polarity = txtPolarity,
                      length   = txtDocLength)
head(allTree)

set.seed(1237)
tmap <- treemap(allTree,
                index   = c("topic","length"),
                vSize   = "length",
                vColor  = "polarity",
                type    ="value", 
                title   = "Guardan Articles mentioning Pakistan",
                palette = c("red","white","green"))

tmap

# End
