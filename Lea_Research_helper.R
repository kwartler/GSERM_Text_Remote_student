#' Title: Fiji Doc metrics
#' Purpose: read pdfs and extract informnation for analysis
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: May-25-2020
#' Another Options worth exploring
#'https://cran.r-project.org/web/packages/textmineR/vignettes/c_topic_modeling.html
#'

# wd
setwd('/Users/edward.kwartler/Downloads/Fiji minutes') #folder of a bunch of PDFs

# libs
library(pdftools)
library(stringr)
library(udpipe)
library(reshape2)

# Grab universal dependency library; only have to do this once
udModel <- udpipe_download_model(language = "english", 
                                 model_dir = '~/Documents/GSERM_Text_Remote_admin/lessons/E_SyntacticParsing_DataSources/data')

# Load into environment
udModel <- udpipe_load_model('~/Documents/GSERM_Text_Remote_admin/lessons/E_SyntacticParsing_DataSources/data/english-ewt-ud-2.4-190531.udpipe')

# Lea's Cleaning
clean <- function(x){
  x <-tolower(x)
  x <-removeWords(x,stopwords('en'))
  # you may want to insert something to remove urls, because I noticed this in the first passage after cleaning: wwwlogclusterorg
  x <-removePunctuation(x)
  x <-stripWhitespace(x)
  x <- removeNumbers(x) #added this to improve speed, since I think nums aren't what you are looking for
  print('doc complete') #I added this in case you have thousands of docs you will know you are making progress
  return(x) 
}

# i/o
tmp <- list.files(pattern = '.pdf') #KEEP IN MIND THE ORDER IS NOT TEMPORAL
allFiles <- lapply(tmp, pdf_text)
names(allFiles) <- gsub('.pdf','', tmp)

# Get number of pages
pageNum <- sapply(allFiles, length)

# Avg Words per page
wordsPerPg <- lapply(allFiles, function(x){sapply(strsplit(x, " "), length)}) # this is ragged, meaning one value per page and the docs are different lengths
avgWordsPg <- round(sapply(wordsPerPg, mean),2) # this is the avg for an entire doc

# Total Words in doc
totalWordsDoc <- sapply(wordsPerPg, sum)

# Avg NumChars per page
nCharsPerPg <- lapply(allFiles, nchar)
avgNCharPerPg <- round(sapply(nCharsPerPg, mean),2)

# NumChars per doc
totalChars  <- sapply(nCharsPerPg, sum)

# Clean up the text
cleanAllFiles <- lapply(allFiles, clean)

# Collapse each page into a single doc to get 13
text <- sapply(cleanAllFiles, paste, collapse = ' ')
doc_id <- names(allFiles)
allTxt <- data.frame(doc_id, text)

# There are some unrecognized characters i.e. "<U+F0B7>" bracketX is from qdap removes these but we can also do with gsub
#bracketX()
allTxt$text <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", allTxt$text)
allTxt$text <- gsub("U00..", "", allTxt$text)

### Now let's parse this text
# First chk encoding to make sure its utf-8 or similar; check the ud pipe class script for explanation
lapply(cleanAllFiles, Encoding)

# Parse and review
syntatcicParsing <- udpipe(allTxt[1:nrow(allTxt),], object = udModel)
head(syntatcicParsing)
tail(syntatcicParsing)
length(unique(syntatcicParsing$token)) #there are ~1500 unique terms.  You can see each individual token and the parser's lemmatized version by looking at columns token and lemma

# Notice in head(syntatcicParsing) the word logstics (with S) is lemmatized to logistic.  The code below will choose the lemmatized word if one exists.  If it is NA, no lemmatized version exists it will retain the original 
syntatcicParsing$cleanTxt <- ifelse(is.na(syntatcicParsing$lemma), 
                                    syntatcicParsing$token, 
                                    syntatcicParsing$lemma)

# The data frame keeps track of the doc_id so we can aggregate the lemmatized words back into the actual docs
lemmaText        <- aggregate(syntatcicParsing$cleanTxt,
                              list(syntatcicParsing$doc_id), paste, collapse=" ")
names(lemmaText) <- c('doc_id', 'text')

# Examine first doc
lemmaText[1,2]
# I would use write.csv() to get a lemmatized version of the text so you can avoid redoing this work

# So now you have a lemmatized version of your text and can rebuild a DTM for more analysis.

# You can also get dense data about the document that are created in the process
partsOfSpeech <- reshape2::dcast(syntatcicParsing, doc_id ~  xpos)
partsOfSpeechChk <- table(syntatcicParsing$doc_id, syntatcicParsing$xpos) #just checking the previous function results in the same data :) I reviews the top row among both

# Now let's assemble the DF of document KPI
finalDF <- data.frame(partsOfSpeech, pageNum, 
                      avgWordsPg, totalWordsDoc, 
                      avgNCharPerPg, totalChars)

# Examine KPI
head(finalDF)

# I notice you are merging with an Excel file using cbind.  I suggest doing an official join to avoid errors.  It is much safer (trust me I have made that error).  Something like below
minutesInfo <- xlsx::read.xlsx()

finalDF <- dplyr::left_join(finalDF, minutesInfo, by = c('doc_id',''))

# End