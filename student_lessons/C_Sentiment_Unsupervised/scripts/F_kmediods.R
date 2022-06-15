#' Title: K Mediods
#' Purpose: apply k Mediod clustering to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#' https://cran.r-project.org/web/packages/kmed/vignettes/kmedoid.html

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/C_Sentiment_Unsupervised/data")

# Libs
library(kmed)
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
stops <- c(stopwords('SMART'), 'work')

# Read & Preprocess
txtMat <- cleanMatrix(pth = 'basicResumes.csv', 
                      columnName  = 'text', # clue answer text 
                      collapse = F, 
                      customStopwords = stops, 
                      type = 'DTM', 
                      wgt = 'weightTfIdf') #weightTf or weightTfIdf

# Remove empty docs w/TF-Idf
txtMat <- subset(txtMat, rowSums(txtMat) > 0)

# Use a manhattan distance matrix; default for kmed
manhattanDist <- distNumeric(txtMat, txtMat, method = "mrw")

# Calculate the k-mediod
txtKMeds <- fastkmed(manhattanDist, ncluster = 5, iterate = 5)

# Number of docs per cluster
table(txtKMeds$cluster)
barplot(table(txtKMeds$cluster), main = 'k-mediod')

# Silhouette
silPlot          <- silhouette(txtKMeds$cluster, manhattanDist)
plot(silPlot, col=1:max(txtKMeds$cluster), border=NA)

# Median centroid documents:
txtKMeds$medoid

# End