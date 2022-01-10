#' Title: Spell Check Examples
#' Purpose: Run through basic spell checking of text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 10, 2021
#'

# Libs
#library(qdap) #pg 45 in book has another option but may crash cloud instance
library(spelling)
library(hunspell)
library(mgsub)

# List available dictionaries; not great
# https://cloud.r-project.org/web/packages/hunspell/vignettes/intro.html#hunspell_dictionaries
hunspell:: list_dictionaries()

# Get some text
exampleTxtA <- 'i luve coffe'
exampleTxtB <- "coffee is wunderful"
exampleTxtC <- 'I luve coffee'
allTxt      <- c(exampleTxtA, exampleTxtB, exampleTxtC)

# Declare any words you want to ignore, ie twitters "RT" or "SMH"
ignoreWords <- c('luve')

# Identify mispelled words
#spell_check_files(path, ignore = ignoreWords, lang = "en_US") #check files on disk
spell_check_text(allTxt, lang = "en_US")
spell_check_text(allTxt, ignore = ignoreWords, lang = "en_US")

# No good correction functions, book pg 46
mispelled <- spell_check_text(allTxt, lang = "en_US")
corrected <- hunspell_suggest(mispelled$word)

# Review
mispelled
corrected

# Add word boundaries around the correction lexicon
correctionLexicon <- data.frame(wrong = paste0('\\b', mispelled$word,'\\b'),
                                right = c(corrected[[1]][1],
                                          corrected[[2]][6],
                                          corrected[[3]][1]))

correctionLexicon

# Loop each doc through all possible mispellings, another method could use mispelled$found 
correctedTxt <- vector()
for( i in 1:length(allTxt)){
  print(paste('correcting', i))
  txt <- allTxt[i]
  for(j in 1:nrow(correctionLexicon)){
    txt <- gsub(correctionLexicon$wrong[j],
                correctionLexicon$right[j],
                txt)
  }
  correctedTxt[i] <- txt
}

correctedTxt

# Or with mgsub
mgsub(allTxt, 
      correctionLexicon$wrong, 
      correctionLexicon$right)

# End