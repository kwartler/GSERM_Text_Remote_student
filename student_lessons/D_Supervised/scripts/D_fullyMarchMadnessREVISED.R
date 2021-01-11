#' Title: Fully March Madness Revised
#' Purpose: apply a logistic regression to basketball data
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

# Libs
library(vtreat)
library(MLmetrics)
library(pROC)
library(ggplot2)

# wd
setwd("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/D_Supervised/data")

# Data
bball <- read.csv('ncaa.csv')

# Idenfity the informative and target
names(bball)
targetVar       <- names(bball)[51]
informativeVars <- names(bball)[3:47]

# Review to get familiar
head(bball[,1:7])
head(bball[,47:51])

# Design a "C"ategorical variable plan 
plan <- designTreatmentsC(bball, 
                          informativeVars,
                          targetVar, 1)

# Apply to xVars
treatedX <- prepare(plan, bball)

# Fit a logistic regression model
fit <- glm(R1.Class.1.win ~., data = treatedX, family ='binomial')
summary(fit)

# Backward Variable selection to reduce chances of multi-colinearity
# Takes 2m  to run so load a pre-saved copy that I already made 
#bestFit <- step(fit, direction='backward')
#saveRDS(bestFit, 'bestFitNCAA.rds')
bestFit <-readRDS('bestFitNCAA.rds')
summary(bestFit)

# Compare model size
length(coefficients(fit))
length(coefficients(bestFit))

# Get predictions
teamPreds <- predict(bestFit, type='response')
head(teamPreds)

# Classify 
cutoff <- 0.5
teamClasses <- ifelse(teamPreds >= cutoff, 1,0)

# Organize w/Actual
results <- data.frame(Name                = bball$Name,
                      year                = bball$Year,
                      seed                = bball$Seeds,
                      actual              = bball$R1.Class.1.win,
                      ModelClassification = teamClasses)
head(results,12)

# Get a confusion matrix
(confMat <- ConfusionMatrix(results$ModelClassification, results$actual))

# What is the accuracy?
sum(diag(confMat)) / sum(confMat)

# Visually how well did we separate our classes?
ggplot(results, aes(x=teamPreds, color=as.factor(actual))) +
  geom_density() + 
  geom_vline(aes(xintercept = cutoff), color = 'green')


# End
