#' Title: Day 4 Homework
#' Purpose: Build an elastic net classifer & LSA classifier; evaluate both 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#' 

## Your script header should be the following:
#' Title: GSERM REMOTE DAY 3 HW
#' Purpose: 20pts, evaluate polarity/sentiment/clustering
#' NAME: 
#' Date: 

## Keep in mind, there isn't a right, wrong answer here.  This text is small, and we are evaluating the code execution and appropriate sections, steps being taken more than results on this toy data.

# 1. Set the working directory

# 2. Bring in your custom functions "ZZZ_supportingFunctions.R"

# 3. Set options, scipen =999 strings as stringsAsFactors = F

# 4. Use libraries glmnet, tm, yardstick, ggplot2

# 5. Import exampleNews_lableled.csv as an object called txt

# 6. Declare an object "stops" by combining the SMART stop words with 
#'chars', 'cnn', 'post','washington', 'msnbc','breitbart','fox', 'cnnthe'

# 7. Combine "title", "description" & "content" into a single NEW column called "allText" for clearning and then modeling HINT: use paste() but NOT with collapse = ' '; instead use sep = ' ' Then create a corpus called txtCorp and clean it
txt$______ <- paste(______, 
                     ______, 
                     ______, sep =' ')

# 8. Create a corpus from a vector source (use $allText) then apply the cleaning function in an object called txtCorp

# 9. Explore the data.   Note the column "label" 1= liberal, 0=conservative.  Labeling was done according to this graphic: https://www.washingtonpost.com/news/the-fix/wp/2014/10/21/lets-rank-the-media-from-liberal-to-conservative-based-on-their-audiences/
# 9. Continued...What is the tally of articles for each class i.e. how may 1's vs how many 0's?
table(_____$_____)

# 10. Create a DTM called txtModelMatrix then switch it with as.matrix()

# 11. Partition the data with set.seed(1234) into training & validation 80% of the data should be training
set.seed(____)
idx <- sample(1:nrow(txt), ___ * nrow(txt))
training <- txtModelMatrix[___,]
validation<- txtModelMatrix[____,]

# 12. Build an elastic net classifier, explore alpha 0.9: how many terms are used?  Refit the model with alpha 0.1 how many terms are used.  This parameter tunes the amount of bias and therefore how much information you let into your model. 
set.seed(1234)
textFit <- cv.glmnet(training,
                     y            = as.factor(txt$label[idx]),
                     alpha        = ___,
                     family       = 'binomial',
                     type.measure = 'auc',
                     nfolds       = 5,
                     intercept    = F)

# 13. Model Term exploration code...Subset to the largest impacting terms in our model.  You will want to examine this with both alphas to see the impact of bias
bestTerms <- subset(as.matrix(coefficients(textFit)), 
                    as.matrix(coefficients(textFit)) !=0)
bestTerms <- data.frame(term   = rownames(bestTerms),
                        impact = bestTerms)
bestTerms <- bestTerms[order(bestTerms[,2], decreasing = T),]

# 13. continued...Examine the top 25 bestTerms
head(_________,25)

# 13. continued...Examine the bottom 25 bestTerms

# Compare the terms in the model to the column in the training set
nrow(_______)
ncol(_______)

# 14. Predict the training & validation set.  Remember you can get probabilities using type = 'response' but it's not needed here.
trainingPreds   <- _______(textFit, __________, type = 'class') 
validationPreds <- _______(_______, validation, type = 'class')

# 15. Assess the training partition by creating a visual mosaic plot and calculating accuracy
autoplot(conf_mat(table(trainingPreds,txt$label[idx])))
accuracy(table(txt$label[idx],trainingPreds))

# 15. Continued...Assess the validation partition by creating a visual mosaic plot and calculating accuracy
________(conf_mat(_____(_______________,txt$label[-idx])))
# End