#' Title: Read TXT files
#' Purpose: Read .txt
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 29 2020
#'

# Read in a txt file (change this to your file)
txt1 <- readLines('https://raw.githubusercontent.com/kwartler/GSERM_TextMining/cacd1d9131fef31309d673b24e744a6fee54269d/E_Friday/data/clinton/C05758905.txt')

# Examine
txt1

# Collapse all lines to make it like a single giant document
txt2 <- paste(txt1, collapse = ' ')

# split on a string "Doc No." to demonstrate getting a single document to
# individual documents
indDocs <- strsplit(txt2, "Doc No.")

# The result is a list object so can be worked with this way
indDocs[[1]][1] # first doc
indDocs[[1]][2] # second doc
indDocs[[1]][3] # third doc

# or "unlist" the object, but this can be challenging if the list is complex
indDocs <- unlist(indDocs)
indDocs[1] # first Doc
indDocs[2] #second doc
indDocs[3] #third doc

# End


