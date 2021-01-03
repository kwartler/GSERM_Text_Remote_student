#' Title: Emotional Context & Clustering for Topics
#' Purpose: Apply NRC to get news source sentiment & cluster to get news topics
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020

# wd
setwd("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data")

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
library(dplyr)
library(plyr)
library(radarchart)
library(ggplot2)
library(ggthemes)

# Custom Functions
source('/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
source('/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_plotCluster.R')

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


pdf(file = "/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data/news_cluster_topics.pdf", 
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
             
# Intersect the Clusters and Sentiment; ID outlier sources
clusterProp <- table(data.frame(txtSKMeans$cluster,
                       clusterSource = cut(1:length(txtSKMeans$cluster), 
                       breaks = seq(0,500,100), 
                       labels = sourceID[,1])))
clusterProp <- prop.table(clusterProp, margin = 1)
clusterProp

# Intersect the Clusters and Sentiment; join the clusters
docCluster <- data.frame(document = names(txtSKMeans$cluster), 
                clusterAssignment = txtSKMeans$cluster)
combinedData <- left_join(nrcSent, docCluster)

# Intersect the Clusters and Sentiment; subset to the cluster of interest
oneTopic <- subset(combinedData, combinedData$clusterAssignment == 1)

# Adjust for quick analysis
table(oneTopic $sentiment, oneTopic $source)
oneEmo <- as.data.frame.matrix(table(oneTopic $sentiment, oneTopic $source))
oneEmo

# Make a radarChart
chartJSRadar(scores = oneEmo, 
             labs = rownames(oneEmo),
             labelSize = 10, showLegend = F)
             
# Intersect the Clusters and Sentiment; subset to one source
oneSource <- subset(combinedData, combinedData$source== sourceID[2,1])
oneSource <- aggregate(count~sentiment+clusterAssignment, oneSource, sum)
oneSource

# Intersect the Clusters and Sentiment; plot the results, you could recode the topics 1-4 to the most frequent words like "trump" etc
levelKey                    <- rownames(protoTypical)[apply(protoTypical,2,which.max)]
names(levelKey)             <- c("1","2","3","4")
oneSource$clusterAssignment <- recode(as.character(oneSource$clusterAssignment), !!!levelKey)
ggplot(oneSource, aes(sentiment, as.factor(clusterAssignment), 
                      size = count, alpha = count)) +
  geom_point() +
  ggtitle("MSNBC", sub = "Emotion by Topic Cluster") + ylab("") +
  theme_tufte()
# End