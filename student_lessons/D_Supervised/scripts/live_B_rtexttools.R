#' Title: Multiple Supervised Methods 
#' Purpose: Explore the rtexttools package
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 16 2021
#' 

# Set the working directory; note we are using the directory from previous day!
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/D_Supervised/data")

# Libs
library(tm)
library(RTextTools)
library(yardstick)

# Bring in our supporting functions
source('~/Desktop/GSERM_Text_Remote_student/student_lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE, scipen = 999)
Sys.setlocale('LC_ALL','C')

# Create custom stop words
stops <- c(stopwords('SMART'), 'diabetes', 'patient')

# Get data
diabetes <- read.csv('diabetes_subset_8500.csv')
txt <- paste(diabetes$diag_1_desc,
             diabetes$diag_2_desc,
             diabetes$diag_3_desc)

# Subset to avoid overfitting
set.seed(1234)
idx <- sample(1:length(txt), floor(length(txt)*.70))
train <- txt[idx]
test  <- txt[-idx]

# Clean, extract text and get into correct object
cleanTrain <- cleanCorpus(VCorpus(VectorSource(train)), stops)
cleanTrain
cleanTrain <- unlist(lapply(cleanTrain, content))
cleanTrain[1]
trainDTMm <- create_matrix(cleanTrain, language="english")

# Create the container
# trainSize; if you want you can split within the single matrix but best practice is to bring it in separate to mimic really new data processing 
container <- create_container(matrix    = trainDTMm,
                              labels    = diabetes$readmitted[idx], 
                              trainSize = 1:length(idx), 
                              virgin=FALSE)

# Build Models, can take ages for complex algos
#models <- train_models(container, algorithms=c("GLMNET","SVM")) #"SVM","SLDA","BOOSTING","BAGGING", "RF","GLMNET","TREE","NNET"
#saveRDS(models, 'rtexttools_models_june152022.rds')
models <- readRDS('rtexttools_models_june152022.rds')


# Score the original training data
results <- classify_models(container, models)
results[59:69,]

# Append Actuals
results$actual <- diabetes$readmitted[idx]

# Confusion Matrix
table(results$GLMNET_LABEL, results$actual)
table(results$SVM_LABEL, results$actual)

# Accuracy GLMNET_LABEL
autoplot(conf_mat(table(results$GLMNET_LABEL, results$actual)))
accuracy(table(results$GLMNET_LABEL, results$actual))

# Accuracy SVM_LABEL
autoplot(conf_mat(table(results$SVM_LABEL, results$actual)))
accuracy(table(results$SVM_LABEL, results$actual))

# Now let's apply the models to "new" documents
# Clean, extract text and get into correct object
cleanTest <- cleanCorpus(VCorpus(VectorSource(test)), stops)
cleanTest <- unlist(lapply(cleanTest, content))

# You have to combine the matrices to the original to get the tokens joined
allDTM  <- c(cleanTrain, cleanTest)
allDTMm <- create_matrix(allDTM, language="english")
containerTest <- create_container(matrix    = allDTMm,
                                  labels    = c(diabetes$readmitted[idx],
                                                diabetes$readmitted[-idx]),
                                  trainSize = 1:length(idx),
                                  testSize  = (length(idx)+1):8500,
                                  virgin=T)

#testFit <- train_models(containerTest, algorithms=c("GLMNET", "SVM"))
#saveRDS(testFit, 'rtexttools_testFit_June152022.rds')
testFit <-readRDS('rtexttools_testFit_June152022.rds')
resultsTest <- classify_models(containerTest, testFit)

# Append Actuals
resultsTest$actual <- diabetes$readmitted[-idx]

# Confusion Matrix
summary(resultsTest$GLMNET_PROB)
summary(resultsTest$SVM_PROB)
table(resultsTest$SVM_LABEL, resultsTest$actual)
table(resultsTest$GLMNET_LABEL, resultsTest$actual)

# End