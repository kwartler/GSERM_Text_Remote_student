# Real modeling

# wd
setwd("~/Documents/GSERM_Text_Remote_admin/lessons/ZZ_case/studentVersion")

# options
options(scipen = 999)


# libs
library(lsa)
library(glmnet)

# Functions for cleaning
source('~/Documents/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')


# files
tmp <- list.files(pattern = 'student')

# Read both in 
holdout <- read.csv(tmp[1])
training <- read.csv(tmp[2])

# segregate label
yVar <- training$label
training$label <- NULL

# Be sure to get order correct
allTxt <- rbind(training, holdout)

# stops
stops <- stopwords('SMART')

# clean all
allClean <- VCorpus(VectorSource(allTxt$rawText))
allClean <- cleanCorpus(allClean, stops)

# DTM
txtDTM <- DocumentTermMatrix(allClean,  
                             control = list(weighting =
                                              function(x)weightTfIdf(x)))

# Model Mat
modelingData <- as.matrix(txtDTM)

# Training & append the label again
trainingModeling <- modelingData[1:2000,]
trainingModeling <- cbind(trainingModeling, yVar)

# Holdout
holdoutModeling <- modelingData[2001:3000,]

# Partition 
set.seed(123)
idx <- sample(1:nrow(trainingModeling), 1500)
trainingData <- trainingModeling[idx,]
testingData <- trainingModeling[-idx,]

textFit <- cv.glmnet(trainingData[,-ncol(trainingData)],
                     y=as.factor(trainingData[,ncol(trainingData)]),
                     alpha=0.9,
                     family='binomial',
                     type.measure='auc',
                     nfolds=3,
                     intercept=F)

testResults <- predict(textFit,testingData[,-ncol(testingData)],
                       type = 'class' )
table(as.factor(testResults), 
      as.factor(testingData[,ncol(testingData)]))

testResults <- predict(textFit,holdoutModeling,
                       type = 'class' )
table(testResults)

#### LSA
txtTDM <- TermDocumentMatrix(allClean,  
                             control = list(weighting =
                                              function(x)weightTfIdf(x)))
# Use LSA to reduce dimensions
lsaFit <- lsa(txtTDM, dim = 20)

# Training, Testing and holdout organization
trainingModeling <- lsaFit$dk[1:2000,]
trainingModeling <- cbind(trainingModeling, yVar)

# Holdout
holdoutModeling <- as.data.frame(lsaFit$dk[2001:3000,])

# Partition 
set.seed(123)
idx <- sample(1:nrow(trainingModeling), 1500)
trainingData <- as.data.frame(trainingModeling[idx,])
testingData <- as.data.frame(trainingModeling[-idx,])

fit <- glm(yVar~., trainingData, family = 'binomial')
pred <- predict(fit, testingData, type = 'response')
table(ifelse(pred>0.5,1,0), testingData$yVar)
newPred <- predict(fit, holdoutModeling, type = 'response')
table(ifelse(newPred>0.5,1,0))

# End
