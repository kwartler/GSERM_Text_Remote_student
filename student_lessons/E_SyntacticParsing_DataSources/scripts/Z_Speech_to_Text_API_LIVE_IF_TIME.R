#' Title: Speech to Text
#' Purpose: Use an API to perform speech to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 16, 2022
#' googleLanguageR is a package to perform the speech to text  but there are other APIs
#' Refs: https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html
#' http://code.markedmondson.me/googleLanguageR/index.html
#' IT COSTS MONEY, SO BE CAREFUL

# libs
library(googleLanguageR)

#wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/E_SyntacticParsing_DataSources/data")

# Authenticate
#gl_auth('~/Documents/course repos/speech2txt-25cb48408ae7.json')


#### General NLP API
# Google NLP - Named Entity Analysis (R has this for free w/library openNLP)
# Google NLP - Part of Speech Tagging (R has this for free w/library UDpipe)
# Google NLP - Sentiment (R has this for free w/multiple libs and approaches)
# Google NLP - Document Tagging (R *could* do this as a multi-class problem)
texts     <- paste(readLines(paste0(getwd(),'/clinton/C05791318.txt')), 
                   collapse = ' ')
#nlpResult <- gl_nlp(texts)
#saveRDS(nlpResult,'nlpResult.rds')
nlpResult <-readRDS('nlpResult.rds')

# POS tagging & meta
nlpResult$sentences
nlpResult$tokens
nlpResult$language

# Sentiment
nlpResult$documentSentiment$score

# Tagged Topic
nlpResult$classifyText

#### Google Translation API
text <- "Text Mining in Practice with R. It's the math of talking, you're two favorite things! "

## translate British into Danish
#translatedTxt <- gl_translate(text, target = "da") #Norwegian
#saveRDS(translatedTxt, 'translatedTxt.rds')
translatedTxt <- readRDS('translatedTxt.rds')
translatedTxt

#### Speech to Text
#http://www.voiptroubleshooter.com/open_speech/american.html
#speechToTxt <- gl_speech('trimmed.wav', sampleRateHertz = 8000)
#saveRDS(speechToTxt, 'speechToTxt.rds')
speechToTxt <- readRDS('speechToTxt.rds')

# Results
speechToTxt$transcript

# Timed Text
speechToTxt$timings

# Back to audio; not exactly sure why you want to; requires the text-to-speech api enabled
#gl_talk_player(gl_talk(paste(speechToTxt$transcript$transcript, collapse = '')))
# open "player.html" to play "output.wav" or if you have an audio play just click .wav file

# End