#' Title: Spherical K Means
#' Purpose: apply cosine similarity kmeans clustering
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 16, 2021
# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/C_Sentiment_Unsupervised/data")

# Libs
library(skmeans)
library(tm)
library(clue)
library(cluster)
library(wordcloud)

# Bring in our supporting functions
source('~/Desktop/GSERM_Text_Remote_student/student_lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Stopwords
stops  <- c(stopwords('SMART'), 'jeopardy')

# Read & Preprocess
txtMat <- cleanMatrix(pth = 'jeopardyArchive_1000.fst', 
                      columnName  = 'clue', # clue answer text 
                      collapse = F, 
                      customStopwords = stops, 
                      type = 'DTM', 
                      wgt = 'weightTfIdf') #weightTf or weightTfIdf

# Remove empty docs w/TF-Idf
txtMat <- subset(txtMat, rowSums(txtMat) > 0)

# Apply Spherical K-Means
txtSKMeans <- skmeans(txtMat, # data
                      3, #clusters
                      m = 1, #"fuzziness of cluster" 1 = hard partition, >1 increases "softness"
                      control = list(nruns = 5, verbose = T))
barplot(table(txtSKMeans$cluster), main = 'spherical k-means')
dev.off()

# Silhouette plot
sk <- silhouette(txtSKMeans)
plot(sk, col=1:3, border=NA)
dev.off()

# ID protypical terms
protoTypical           <- t(cl_prototypes(txtSKMeans))
colnames(protoTypical) <- paste0('cluster_',1:ncol(protoTypical))
head(protoTypical)
comparison.cloud(protoTypical, scale = c(.5,3))
dev.off()


clusterWC <- list()
for (i in 1:ncol(protoTypical)){
  jsWC <- data.frame(term = rownames(protoTypical),
                     freq = protoTypical[,i])
  jsWC <- jsWC[order(jsWC$freq, decreasing = T),]
  clusterWC[[i]] <- wordcloud2::wordcloud2(head(jsWC[1:500,]))
  print(paste('plotting',i))
}

clusterWC[[1]]
clusterWC[[2]]
clusterWC[[3]]


# Examine a portion of the most prototypical terms per cluster; usually presidents, geography & sometimes authors/playwrites
nTerms <- 10
(clustA <- sort(protoTypical[,1], decreasing = T)[1:nTerms])
(clustB <- sort(protoTypical[,2], decreasing = T)[1:nTerms]) 
(clustC <- sort(protoTypical[,3], decreasing = T)[1:nTerms]) 

# End