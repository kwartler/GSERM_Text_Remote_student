#' TK
#' Load, and clean Dell Forum
#' 

# Libs
library(fst)
library(tm)
library(qdap)

# Wd
setwd("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_student/lessons/B_Basic_Visuals/data")

# Inputs
pth <- '2020-12-18_dellForum_k1_k5540.fst'
testing <- F
stops <- c(stopwords('SMART'), 'dell')

# Load custom functions
source('~/Desktop/GSERM_Text_Remote_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Load my Data
if(testing==T){
  print('you are only loading 100 rows')
  txt <- read_fst(pth, from = 1, to = 100)
} else {
  print('you are loading everything')
  txt <- read_fst(pth)
}

# Make corpus and clean
cleanTxt <- VCorpus(VectorSource(txt$post))
cleanTxt <- cleanCorpus(cleanTxt, stops)
df <- data.frame(text = unlist(sapply(cleanTxt, `[`, "content")),
                 stringsAsFactors=F)

# Save the clean version
write_fst(df, "~/Desktop/cleanTxt.fst")

# End