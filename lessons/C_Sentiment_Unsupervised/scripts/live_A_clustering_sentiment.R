#' Title: Cluster, Polarity & Sentiment
#' Purpose: Apply all methods to a corpus
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June-9-2020

# wd
setwd("~/Documents/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data")

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
source('~/Documents/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
source('~/Documents/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_plotCluster.R')

# Examine Raw Text
rawTxt <- read.csv('exampleNews.csv')
t(rawTxt[1,])

# Organize into a DF for TM
allInfo <- data.frame(doc_id = 1:nrow(rawTxt),
                      text   = paste0(rawTxt$title, 
                                      rawTxt$description, 
                                      rawTxt$content),
                      source = rawTxt$id)

# Now the TM
stops  <- c(stopwords('SMART'),'chars') # API truncation "[+3394 chars]"

# Process
allInfo    <- VCorpus(DataframeSource(allInfo))
allInfo    <- cleanCorpus(allInfo, stops) 
#saveRDS(allInfo, 'allInfo.rds')
allInfo    <- readRDS('allInfo.rds')
allInfoDTM <-  DocumentTermMatrix(allInfo)
allInfoDTM <- as.matrix(allInfoDTM)
allInfoDTM <- subset(allInfoDTM, rowSums(allInfoDTM) > 0)
dim(allInfoDTM)

#### Perform a Spherical K Means Clustering
set.seed(1234)
txtSKMeans <- skmeans(allInfoDTM, 
                      4, 
                      m = 1, 
                      control = list(nruns = 5, verbose = T))

# Examine Separation
barplot(table(txtSKMeans$cluster), main = 'spherical k-means')
plot(silhouette(txtSKMeans), col=1:2, border=NULL)

# What are the terms of our 2 clusters
# ID protypical terms
protoTypical           <- t(cl_prototypes(txtSKMeans))
colnames(protoTypical) <- paste0('cluster_',1:ncol(protoTypical))
head(protoTypical)


pdf(file = "~/Documents/GSERM_Text_Remote_admin/personal/news_cluster_topics.pdf", 
    width  = 6, 
    height = 6) 
comparison.cloud(protoTypical, title.size=1.1, scale=c(1,.5))
dev.off()

#### Perform an NRC Sentiment Inner Join
tidyCorp <- tidy(DocumentTermMatrix(allInfo))
tidyCorp

# Let's understand the meta data of new source
(sourceID <- unique(meta(allInfo)))

# Cut documents into the 5 sources
# Teachable moment: "one less than the state of nature"
seq(0,500,100) 
length(seq(0,500,100))
# How do you represent 6 states of nature in a factor?  with 5 levels!
#With cut(), 6 breaks delimit 5 levels which will require only 5 labels!
tidyCorp <- as.data.frame(tidyCorp)
tidyCorp$source <- cut(as.numeric(tidyCorp$document), 
                       breaks = seq(0,500,100), 
                       labels = sourceID[,1])
tidyCorp[2944:2948,]

# In B_sentimentAnalysis.R we reshaped the NRC now we just load it
nrc <- read.csv('tidy_nrcLex.csv')

# Perform the inner join
nrcSent <- inner_join(tidyCorp,
                      nrc, by=c('term' = 'term'))
head(nrcSent)

# Adjust for quick analysis
table(nrcSent$sentiment, nrcSent$source)
emos <- as.data.frame.matrix(table(nrcSent$sentiment,nrcSent$source))
emos

# Make a radarChart
chartJSRadar(scores = emos, 
             labs = rownames(emos),
             labelSize = 10, showLegend = F)

# End