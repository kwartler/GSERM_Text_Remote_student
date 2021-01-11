#' Title: Latent Semantic Analysis
#' Purpose: apply lsa to reduce dimensionality
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#' Another good option
#'https://cran.r-project.org/web/packages/textmineR/vignettes/c_topic_modeling.html

# Set the working directory
setwd("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data")

# Libs
library(tm)
library(lsa)

# Bring in our supporting functions
source('/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE, scipen = 999)
Sys.setlocale('LC_ALL','C')

# Create custom stop words
stops <- c(stopwords('SMART'), 'car', 'electronic')

# Bring in some data
carCorp <- VCorpus(DirSource("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data/AutoAndElectronics/rec.autos"))
electronicCorp <- VCorpus(DirSource("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/C_Sentiment_Unsupervised/data/AutoAndElectronics/rec.autos"))

# Clean each one
carCorp        <- cleanCorpus(carCorp, stops)
electronicCorp <- cleanCorpus(electronicCorp, stops)

# Combine
allPosts <-  c(carCorp,electronicCorp)
rm(carCorp)
rm(electronicCorp)
gc()

# Construct the Target
yTarget <- c(rep(1,1000), rep(0,1000)) #1= about cars, 0 = electronics

# Make TDM; lsa docs save DTM w/"documents in colums, terms in rows and occurrence frequencies in the cells."!
allTDM <- TermDocumentMatrix(allPosts, 
                             control = list(weighting = weightTfIdf))
allTDM

# Get 20 latent topics
##### Takes awhile, may crash small computers, so saved a copy
#lsaTDM <- lsa(allTDM, 20)
#saveRDS(lsaTDM, 'lsaTDM_tfidf.rds')
lsaTDM <- readRDS('lsaTDM_tfidf.rds')

##### Experimental...usually LSA is performed for supervised document modeling
# Now you have dense and small data, you can subset docs by max value and perform frequency analysis for each document group.  You can also use the dense data for applying an unsupervised algorithm itself instead of the "max" column approach which is pretty naive.  
reducedTopicSpace <- as.data.frame(as.matrix(lsaTDM$dk))
maxTopic  <- max.col(reducedTopicSpace)
lsaResult <- data.frame(rownames(reducedTopicSpace), maxTopic)
head(lsaResult)
table(lsaResult$maxTopic)

# End