#' Title: Day 3 Homework
#' Purpose: Testing your knowledge of sentiment/polarity and unsuprevised approaches
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 23 2020
#' 

## Your script header should be the following:
#' Title: GSERM REMOTE DAY 3 HW
#' Purpose: 20pts, evaluate polarity/sentiment/clustering
#' NAME: 
#' Date: 

## Keep in mind, there isn't a right, wrong answer here.  This text is small, and we are evaluating the code execution and appropriate sections, steps being taken more than results on this toy data.

# HW Tasks:
# 1. Apply 1 sentiment lexicon or polarity analysis to news.csv data.
# 2. Perform 1 clustering method with the news.csv data. 
# Considerations:  
# - The title, description and content columns are all ok to use as well as the combined title_description_content column.  
# - There is a column called newsSite with sources cnn, fox-news, msnbc, the-american-conservative.  You may analyze each news sources individually for your analysis (full credit) or into two groups i.e. right or left leaning (-1pt), or treat them as a single group therby ignoring the column and just treating it as a single document set (-2 pts because its easiest)
#' Title: GSERM REMOTE DAY 3 HW
#' Purpose: 20pts, evaluate polarity/sentiment/clustering
#' NAME: Pauline Lemaire
#' Date: 10 June 2020

# wd
setwd("~/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/HW")

# options
options(scipen = 999, stringsAsFactors = F)

# Libs
library(skmeans)
library(tidytext)
library(tm)
library(clue)
library(cluster)
library(wordcloud)
library(lexicon)
library(plyr)
library(dplyr)
library(radarchart)

# Custom Functions
source('~/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
source('~/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_plotCluster.R')

# Examine text
News <- read.csv("news.csv")
t(News[1,])

# Organizing relevant data into a data frame. Selecting "title_description_text" as the data I am interested in. 
NewsText <- data.frame(doc_id = 1:nrow(News),
                       text   = News$title_description_content,  # selected the useful data 
                       source = News$newsSite)  # added the source of each item

# Creating stopwords
stops  <- c(stopwords('SMART'),'chars') # from observing content, I see that there is API truncation "[+8264 chars]" 

# Building a volatile corpus, cleaning it, passing it as a document term matrix
NewsText     <- VCorpus(DataframeSource(NewsText))
NewsText     <- cleanCorpus(NewsText, stops) 
NewsTextDTM  <-  DocumentTermMatrix(NewsText)
NewsTextDTM  <- as.matrix(NewsTextDTM)
NewsTextDTM  <- subset(NewsTextDTM, rowSums(NewsTextDTM) > 0)
dim(NewsTextDTM)

## 1. Perform 1 sentiment analysis: NRC innerjoin sentiment analysis
tidyNews <- tidy(DocumentTermMatrix(NewsText)) # remove 0 and dense data format
tidyNews

# Examine the metadata of news source
(sourceID <- unique(meta(NewsText))) # 4 different news sources

# Cutting the documents into the four identified sources
tidyNews <- as.data.frame(tidyNews) #treat the tibble as a dataframe
tidyNews$source <- cut(as.numeric(tidyNews$document), #add a source column
                       breaks = c(0,66,150,154,254), #break it into 4 groups
                       labels = sourceID[,1])
tidyNews[6546:6551,]

# Loading NRC lexicon prepared this morning 
nrc <- read.csv('~/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data/tidy_nrcLex.csv')

# Perform the inner join
nrcSent <- inner_join(tidyNews,
                      nrc, by=c('term' = 'term'))
head(nrcSent)

# Adjust for  analysis
table(nrcSent$sentiment, nrcSent$source)
sentiment <- as.data.frame.matrix(table(nrcSent$sentiment,nrcSent$source))
sentiment

# Make a chart radar to compare the four news sources 
chartJSRadar(scores = sentiment, 
             labs = rownames(sentiment),
             labelSize = 10, showLegend = F)
### Fox News seems to rely a lot more than the other on strong emotions such as anger and sadness. 

## 2.Perform a clustering method: Spherical K Means Clustering - using the Document term matrix created earlier
set.seed(1564)
newsSKMeans <- skmeans(NewsTextDTM, 
                       3, 
                       m = 1, 
                       control = list(nruns = 5, verbose = T))

# Visualizing separation 
barplot(table(newsSKMeans$cluster), main = 'spherical k-means')
plot(silhouette(newsSKMeans), col=1:2, border=NULL) 

# Analyzing prototypical terms
protoTypical           <- t(cl_prototypes(newsSKMeans))
colnames(protoTypical) <- paste0('cluster_',1:ncol(protoTypical))
head(protoTypical)
comparison.cloud(protoTypical)
### it seems that one cluster is concerned with protests related to the death of George Floyd (cluster 2), one with the coronavirus (cluster 1), and one with the conservative perspective on American foreign policy (cluster 3). 


# End


# End