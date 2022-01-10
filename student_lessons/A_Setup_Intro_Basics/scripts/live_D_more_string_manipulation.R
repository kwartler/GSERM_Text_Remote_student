#' Title: R Sting Basics Stringi & Stringr
#' Purpose: Explore a bunch of functions from the most common string manipulations packages
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Jan 9, 2022
#' 

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/A_Setup_Intro_Basics/data")

# library
library(stringi)
library(stringr)

# Suppose these two sentances were two huge pieces of text
txt  <- '<b>THIS IS ALL CAPS</b> <br>'
txt2 <- 'this is not in caps          '
txt3 <- 'this is NOT a long sentence is it?'

# Lowercase
txt <- tolower(txt)
txt

# global substitution
gsub('<br>', '~~~~some html~~~~', txt) #replace with something
gsub('<br>', '', txt) #find specific and replace w nothing
txt <- gsub("<.*?>",'', txt )#find with wildcard, replace w nothing
txt

# Let's combine our three separate objects
allText <- c(txt, txt2, txt3)

# Again let's find terms
grep('not', allText, ignore.case = T) # index position
grepl('NOT', allText) # Case matters!
grepl('NOT', allText, ignore.case = T)

# There are literally hundreds of functions in stringi and stringr here are just a few
## stringi examples
# Exact character position of the term "NOT" for each document
whereIsNot <- stri_locate_all(allText, fixed = 'not')
whereIsNot # this is a list!

# Instead of fixed we can use RegEx
whereIsNot <- stri_locate_all(allText, regex = 'not', case_insensitive=TRUE)
whereIsNot # this is a list!

# Grep gives you presence of at least one, either index of T/F, this is a count
stri_count(allText, fixed="is")
stri_count(allText, regex="\\bis\\b")

# There may be times we need to break up word individually or by a character
str_split(allText, " ") # result is a list!

splitDocs <- str_split(allText, "is")
splitDocs

# Suppose you now want to get the last element of this list?
sapply(splitDocs, tail, 1)

## stringr examples
# Extract terms if they are present
str_extract(allText, 'not')
str_extract(allText, 'this')

# Locate terms if they are present
str_locate_all(allText, fixed('not')) # notice the fixed() is now a stringr control function not parameter
str_locate_all(allText, 'not|NOT') #regex

# Change the capitalization
str_to_upper(allText, locale = "en")
str_to_lower(allText, locale = "en")
str_to_title(allText, locale = "en")
str_to_sentence(allText, locale = "en")

# What about trimming?
str_trim(allText, side = c("both", "left", "right")) #stringr
trimws(allText) #base

# End