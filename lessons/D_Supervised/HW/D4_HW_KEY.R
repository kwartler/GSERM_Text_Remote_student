#' Title: Day 4 Homework
#' Purpose: Build an elastic net classifer & LSA based logistic regression classifier; evaluate both 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 29 2020
#' 

## Your script header should be the following:
#' Title: GSERM REMOTE DAY 4 HW
#' Purpose: 20pts, build & evaluate a classifier
#' NAME: 
#' Date: 

# 1. Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_admin/lessons/D_Supervised/HW")

# 2. Bring in your custom functions "ZZZ_supportingFunctions.R"
source('~/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# 3. Set options, scipen =999 strings as stringsAsFactors = F
options(scipen = 999, stringsAsFactors = F)

# 4. Use libraries glmnet, tm, yardstick, ggplot2
library(glmnet)
library(tm)
library(yardstick)
library(ggplot2)

# 5. Import exampleNews_lableled.csv as an object called txt
txt <- read.csv("exampleNews_labeled.csv")

# 6. Declare an object "stops" by combining the SMART stop words with 
#'chars', 'cnn', 'post','washington', 'msnbc','breitbart','fox', 'cnnthe'
stops <- c(stopwords('SMART'),'chars', 'cnn', 'post','washington',
           'msnbc','breitbart','fox', 'cnnthe')

# 7. Combine "title", "description" & "content" into a single NEW column called "allText" for clearning and then modeling HINT: use paste() but NOT with collapse = ' '; instead use sep = ' ' Then create a corpus called txtCorp and clean it
txt$allText <- paste(txt$title, 
                     txt$description, 
                     txt$content, sep =' ')

# 8. Create a corpus from a vector source then apply the cleaning function
txtCorp <- VCorpus(VectorSource(txt$allText))
txtCorp <- cleanCorpus(txtCorp, stops)

# 9. Explore the data.   Note the new column "label" 1= liberal, 0=conservative.  Labeling was done according to this graphic: https://www.washingtonpost.com/news/the-fix/wp/2014/10/21/lets-rank-the-media-from-liberal-to-conservative-based-on-their-audiences/
# 9. Continued...What is the tally of articles for each class i.e. how may 1's vs how many 0's?
table(txt$label)

# 10. Create a DTM called txtModelMatrix then switch it with as.matrix()
txtModelMatrix <- as.matrix(DocumentTermMatrix(txtCorp))

# 11. Partition the data with set.seed(1234) into training & validation 80% of the data should be training
set.seed(1234)
idx <- sample(1:nrow(txt), 0.8 * nrow(txt))
training <- txtModelMatrix[idx,]
validation<- txtModelMatrix[-idx,]

# 12. Build an elastic net classifier, explore alpha 0.9: how many terms are used?  Refit the model with alpha 0.1 how many terms are used.  This parameter tunes the amount of bias and therefore how much information you let into your model. 
set.seed(1234)
textFit <- cv.glmnet(training,
                     y           = as.factor(txt$label[idx]),
                     alpha=0.1,
                     family='binomial',
                     type.measure='auc',
                     nfolds=5,
                     intercept=F)

# 13. Model Term exploration code...Subset to the largest impacting terms in our model.  You will want to examine this with both alphas to see the impact of bias
bestTerms <- subset(as.matrix(coefficients(textFit)), 
                    as.matrix(coefficients(textFit)) !=0)
bestTerms <- data.frame(term   = rownames(bestTerms),
                        impact = bestTerms)
bestTerms <- bestTerms[order(bestTerms[,2], decreasing = T),]
head(bestTerms,25)
tail(bestTerms,25)
nrow(bestTerms)
ncol(training)

# 14. Predict the training & validation set
trainingPreds <- predict(textFit, training, type = 'class') #response
validationPreds <- predict(textFit, validation, type = 'class')

# 15. Assess the training partition by creating a visual mosaic plot and calculating accuracy
autoplot(conf_mat(table(trainingPreds,txt$label[idx])))
accuracy(table(txt$label[idx],trainingPreds))

# 15. Continued...Assess the validation partition by creating a visual mosaic plot and calculating accuracy
autoplot(conf_mat(table(validationPreds,txt$label[-idx])))
# End