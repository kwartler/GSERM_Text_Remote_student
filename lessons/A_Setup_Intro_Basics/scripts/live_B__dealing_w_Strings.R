#' Title: String Search Manipulation
#' Purpose: Learn some basic string manipulation functions
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: May 23-2020
#'

# Set the working directory
setwd("/cloud/project/lessons/A_Monday/data/tweets")

# Libs
library(stringi)

# Options & Functions
options(stringsAsFactors = FALSE) #text strings will not be factors of categories
Sys.setlocale('LC_ALL','C') #some tweets are in different languages so you may get an error

# Get Data
text <- read.csv('coffee.csv', header=TRUE)

# Logical T/F vector that a string appears at least ONCE
coffee    <- grepl("coffee", text$text, ignore.case=TRUE)
starbucks <- grepl("starbucks", text$text, ignore.case=TRUE)

# Review Logical Output
head(starbucks, 10)

# Find the row positions of a specific word appearing at least ONCE
#this shows the difference between grep and grepl
grep("mug", text$text, ignore.case=TRUE)

# Grep for indexing
text[grep('mug', text$text),2]

# Logical T/F for one word OR another appears at least ONCE
keywordsOR  <-"mug|glass|cup"
mugGlassCup <- grepl(keywordsOR, text$text,ignore.case=TRUE)
head(text$text[mugGlassCup])

# Logical Search AND operator, regular expression
keywordsAND <- "(?=.*mug)(?=.*cute)"
cuteMug     <- grepl(keywordsAND, text$text,perl=TRUE)
head(text$text[cuteMug])

# Calculate the % of times among all tweets
sum(coffee) / nrow(text)
sum(starbucks) / nrow(text)
sum(mugGlassCup) / nrow(text)

# Count occurences of words per tweet
text$text[654]
theCoffee     <- stri_count(text$text, fixed ="the")
theCoffeeGrep <- stri_count(text$text, regex ="\\bthe\\b") #anchored, nearly equivalent
identical(theCoffee, theCoffeeGrep)
theCoffee[654]
theCoffeeGrep[654]
sum(theCoffee) / nrow(text)

# Suppose you want to make regular expression substitutions
originalCup <- text[grep("mug", text$text),]
originalCup[1:3,2]
gsub('mug', 'cup', originalCup[1:3,2])

# BE VERY CAREFUL! Sometimes Anchors matter!! Let's remove the RT (retweets)
exampleTxt <- 'RT I love the Statue of Liberty'
gsub('rt','', exampleTxt)
gsub('rt','', exampleTxt, ignore.case = T)
gsub('^RT','' ,exampleTxt) #another type of anchor
gsub('\\bRT\\b','' ,exampleTxt) # escaped "\b" is actually a "backspace" thus its only looking for that


# End