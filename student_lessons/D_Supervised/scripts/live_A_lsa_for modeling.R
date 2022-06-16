#' Title: LSA for Modeling
#' Purpose: use LSA to reduce dimensions and create a model
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 16 2021

# Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/D_Supervised/data/AutoAndElectronics")

# Libs
library(tm)
library(lsa)
library(yardstick)
library(ggplot2)

# Bring in our supporting functions
source('~/Desktop/GSERM_Text_Remote_student/student_lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE, scipen = 999)
Sys.setlocale('LC_ALL','C')

# Create custom stop words
stops <- c(stopwords('SMART'), 'car', 'electronic')

# Bring in some data
carCorp <- VCorpus(DirSource("rec.autos"))
electronicCorp <- VCorpus(DirSource("sci.electronics"))

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

# Make TDM; lsa docs save DTM w/"documents in columns, terms in rows and occurrence frequencies in the cells."!
allTDM <- TermDocumentMatrix(allPosts, 
                             control = list(weighting = weightTfIdf))
allTDM

# Get 20 latent topics
##### Takes awhile, may crash small RAM computers, so saved a copy
#lsaTDM <- lsa(allTDM, 20)
#saveRDS(lsaTDM, '~/Desktop/GSERM_Text_Remote_student/student_lessons/D_Supervised/data/lsaTDM_tfidf_June152022.rds') #be sure to declare the right wd!
lsaTDM <- readRDS('~/Desktop/GSERM_Text_Remote_student/student_lessons/D_Supervised/data/lsaTDM_tfidf_June152022.rds')

# Extract the document LSA values
docVectors <- as.data.frame(lsaTDM$dk)
head(docVectors)

# Append the target var
docVectors$yTarget <- yTarget

# Sample (avoid overfitting)
set.seed(1234)
idx <- sample(1:nrow(docVectors),.6*nrow(docVectors))
training   <- docVectors[idx,]
validation <- docVectors[-idx,]

# Fit the model
fit <- glm(yTarget~., training, family = 'binomial')

# Predict in sample
predTraining <- predict(fit, training, type = 'response')
head(predTraining)

# Predict on validation
predValidation <- predict(fit, validation, type = 'response')
head(predValidation)

# Simple Accuracy Eval
yHat <- ifelse(predValidation >= 0.5,1,0)
(confMat <- table(yHat, validation$yTarget))
summary(conf_mat(confMat))
autoplot(conf_mat(confMat))

# End
