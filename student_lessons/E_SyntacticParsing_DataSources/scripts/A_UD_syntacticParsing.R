#' Title: UD Syntactic Parsing
#' Purpose: Apply syntactic parsing
#' Author: Ted Kwartler
#' email: ehk116@gmail.com
#' License: GPL>=3
#' Date: June 16, 2022
#'

# Libs
library(udpipe)
library(tm)
library(pbapply)
library(qdap)
library(reshape2)

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/E_SyntacticParsing_DataSources/data")

# Inputs
datPth          <- 'tweets_jairbolsonaro.csv'
testing         <- T
nonBasicStops   <- c('segura', 'seguro')

# Options
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Bring in the cleaning function
source("~/Desktop/GSERM_Text_Remote_student/student_lessons/Z_otherScripts/ZZZ_supportingFunctions.R")

# Get a language model to the server
?udpipe_download_model
udModel <- udpipe_download_model(language  = "portuguese-br",  #"portuguese-gsd"
                                 model_dir = '~/Desktop/GSERM_Text_Remote_student/student_lessons')

# Load into the space
udModel <- udpipe_load_model('~/Desktop/GSERM_Text_Remote_student/student_lessons/portuguese-gsd-ud-2.5-191206.udpipe')
# Bring in data & organize
textData <- read.csv(datPth)
text     <- data.frame(doc_id = 1:nrow(textData),
                       text   = textData$text)

# Convert
#Encoding(text$text)
#iconvlist()
#stringi::stri_enc_detect(text$text)
text$text <- iconv(text$text, "latin1", "ISO-8859-1", sub="")

# Apply the cleaning function, then get the plain text version
textCorp <- VCorpus(DataframeSource(text))
textCorp <- cleanCorpus(textCorp, c(stopwords('portuguese'),nonBasicStops))
text     <- pblapply(textCorp, content)


#text[[1]] #Uh oh!
text     <- pblapply(textCorp, bracketX)
#text[[1]] #better

# Re-organize to keep track of doc_id
text <- data.frame(doc_id = 1:nrow(textData), 
                   text   = unlist(text))

# Reduce for testing
nDocs            <- ifelse(testing ==T, 2, nrow(text))

# UD Pipe require UTF8 so this may be needed to enforce it.
text$text <- enc2utf8(text$text)

syntatcicParsing <- udpipe(text[1:nDocs,], object = udModel)
head(syntatcicParsing)
tail(syntatcicParsing)

# ID and replace any non-lemma terms
syntatcicParsing$cleanTxt <- ifelse(is.na(syntatcicParsing$lemma), 
                                    syntatcicParsing$token, 
                                    syntatcicParsing$lemma)

# Aggregate back to the document level
lemmaText        <- aggregate(syntatcicParsing$cleanTxt,
                              list(syntatcicParsing$doc_id), paste, collapse=" ")

names(lemmaText) <- c('doc_id', 'text')


#text[1,2]
#lemmaText[1,]

# From here you can reapply to get a lemmatized version of a DTM, using tokenization etc
# You can also get dense data about the document
# Codes can be found here: https://universaldependencies.org/u/dep/
reshape2::dcast(syntatcicParsing, doc_id ~  xpos)

# End
