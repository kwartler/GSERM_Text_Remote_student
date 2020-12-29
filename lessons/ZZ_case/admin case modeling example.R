setwd("~/Documents/GSERM_Text_Remote_admin/lessons/ZZ_case")
# Basic Key
library(tm)
library(lsa)
library(data.table)
library(glmnet)

# Data has already been cleaned in key file
txt <- fread('answerKey.csv')
set.seed(1234)
idx <- sample(1:nrow(txt),2000) #max is 2000 on rstudio.cloud
txt <- txt[idx,]
txtCorp <- VCorpus(VectorSource(txt$cleanText))



###LSA
txtTDM <- TermDocumentMatrix(txtCorp,  
                             control = list(weighting =
                                              function(x)weightTfIdf(x)))
# Use LSA to reduce dimensions
lsaFit <- lsa(txtTDM, dim = 20)

modelingData <- data.frame(lsaFit$dk, txt$label)

fit <- glm(txt.label~., modelingData, family = 'binomial')
pred <- predict(fit, modelingData, type = 'response')
table(ifelse(pred>0.5,1,0), txt$label)
table(txt$label)
#       0    1
# 0 1374  199
# 1   54  373


#### Elastic Net
txtDTM <- DocumentTermMatrix(txtCorp,  
                             control = list(weighting =
                                              function(x)weightTfIdf(x)))
modelingData <- as.matrix(txtDTM)
textFit <- cv.glmnet(modelingData,
                     y=as.factor(txt$label),
                     alpha=0.9,
                     family='binomial',
                     type.measure='auc',
                     nfolds=3,
                     intercept=F)

pred <- predict(textFit, modelingData, type = 'class')
table(as.factor(pred), as.factor(txt$label))
#      0    1
# 0 1415  194
# 1   13  378

## Student training copy
student <- data.frame(txt$docID, txt$rawText, txt$label)
names(student) <- c('docID','rawText','label')
write.csv(student, 'student_tm_case_training_data.csv', 
          row.names = F)
## Student scoring copy
txt <- fread('answerKey.csv')
set.seed(2020)
idx <- sample(1:nrow(txt),1000) #max is 2000 on rstudio.cloud
validation <- txt[idx,]
validation <- data.frame(validation$docID, validation$rawText)
names(validation) <- c('docID','rawText')
write.csv(validation,'student_tm_case_test_data.csv', row.names = F)


# End