#' Title: Dealing with Emoji
#' Purpose: Learn and calculate polarity 
#' Author: Ted Kwartler
#' email: edward.kwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 18, 2021
#'

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/Emoji_example")

library(tm) # displays the emojis correctly
library(rtweet) # Get the emoji lexicon or load one manually
library(mgsub) #used for substitutions
library(qdap) #emoticons functions
library(textclean) #another one!

head(emojis)
emojis$code[2]
tail(emojis)
nrow(emojis)

# Read in some data
unicorns <- readRDS('unicorns.rds')

# Ignore the Japanese
unicorns$text[c(720, 829)]
# https://twitter.com/massafrancis/status/1363660144379273216

grep(emojis$code[2], unicorns$text)

# OPTION 1: REMOVE EMOJIS, FAST!
# 1. Remove: GSUB all non-ascii character; this removes all non-English too
# Regex Exaplantion "^" anything but the 1-127th ASCII character is sub'ed to ""
# Yes I had to look that up :)
gsub("[^\x01-\x7F]", "", unicorns$text[c(720, 829)])

# 1A Remove: qdapRegex, removes text based emoticons only!  Special characters remain
data(emoticon)
x <- c("are :-)) it 8-D he XD on =-D they :D of :-) is :> for :o) that :-/",
       "as :-D I xD with :^) a =D to =) the 8D and :3 in =3 you 8) his B^D was")

rm_emoticon(x)
ex_emoticon(x)

# Remove all
st <- Sys.time()
rmTxt <- gsub("[^\x01-\x7F]", "", unicorns$text)
Sys.time() - st #0.01secs for 1k tweets
rmTxt[c(720, 829)]  

# OPTION 2: SUBSTITUE EMOJIS, SLOW!
# 2. Substitute them with the lexicon
# Remember mgsub library is text, pattern then replacement, which is different than normal gsub
mgsub(unicorns$text[c(720, 829)], emojis$code, emojis$description)

# Since emojis are often without spaces:
st <- Sys.time()
subTxt <- mgsub(unicorns$text, 
                emojis$code, 
                paste0(' ', emojis$description,' '))
Sys.time() - st #10x longer for 1000 tweets, imagine more!
subTxt[c(720, 829)] 

# Converts to ASCII so not always helpful
textclean::replace_emoji(unicorns$text[829])

unicorns$text[9]
textclean::replace_emoji(unicorns$text[9])

# End

