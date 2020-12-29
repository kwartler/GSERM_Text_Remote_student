# Organize data for script

# wd
setwd("~/Documents/GSERM_Text_Remote_admin/lessons/ZZ_case/notAnalyzed")

# libs
library(tm)
library(stringi)
library(rvest)

tmp <- list.files()

source('~/Documents/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

stops <- stopwords('SMART')
allFiles <- list()
for(i in 1:length(tmp)){
  x <- read.csv(tmp[i], row.names=NULL)
  x$text <- enc2utf8(x$text)
  x <- cleanCorpus(VCorpus(VectorSource(x$text)), stops)
  allFiles[[i]] <- x
  print(i)
}
sum(unlist(lapply(allFiles, length)))
cleanData <- list()
for(i in 1:length(allFiles)){
  y <- data.frame(text = unlist(sapply(allFiles[[i]],
                                       `[`, "content")),
                  stringsAsFactors=F)
  cleanData[[i]] <- y
  print(i)
}

# labeling
political <- 'cnn|blacklivesmatter|nycprotests|BunkerBoy|antifa|protests2020'

# Merge
cleanedTxt <- list()
for(i in 1:length(tmp)){
  x <- read.csv(tmp[i], row.names=NULL)
  x$label <- ifelse(grepl(political,tmp[i], ignore.case = T)==T,1,0)
  y <- cleanData[[i]][,1]
  x$cleanText <- y
  cleanedTxt[[i]] <- x
  print(i)
}

chk <- duplicated(cleanedTxt[[i]]$text)

nondupe <- lapply(cleanedTxt, function(e) nrow(e) - sum(duplicated(e$text)))
sum(unlist(nondupe))

labeling <- unlist(lapply(cleanedTxt, function(e) table(e$label)))
table(labeling)

rawText   <- pluck(cleanedTxt, 'text')
cleanText <- pluck(cleanedTxt, 'cleanText')
docID     <- pluck(cleanedTxt, 'id')
label     <- pluck(cleanedTxt, 'label')

rawText   <- unlist(rawText)
cleanText <- unlist(cleanText)
docID     <- unlist(docID)
label     <- unlist(label)

finalDF <- data.frame(docID, rawText, cleanText, label)
dupes   <- duplicated(finalDF$cleanText)
finalDF <- finalDF[!dupes,]

head(finalDF)


# Modeling
txt <- read.csv('~/Documents/GSERM_Text_Remote_admin/lessons/ZZ_case/answerKey.csv')
set.seed(1234)
idx <- sample(1:nrow(txt),2000)
txt <- txt[idx,]
txtCorp <- VCorpus(VectorSource(txt$cleanText))

txtDTM <- TermDocumentMatrix(txtCorp,  
                             control = list(weighting =
                                              function(x)weightTfIdf(x)))
lsaFit <- lsa::lsa(txtDTM, dim = 20)





# End