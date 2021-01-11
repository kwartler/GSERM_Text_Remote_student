#' Title: Pyramids plots
#' Purpose: Comparative visualizations for text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

# Set the working directory
setwd("/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/B_Basic_Visuals/data")

# Libs
library(tm)
library(qdap)
library(plotrix)
library(ggplot2)
library(ggthemes)
library(ggalt)

# Bring in our supporting functions
source('/Users/edwardkwartler/Desktop/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Create custom stop words
stops <- c(stopwords('SMART'), 'amp', 'britishairways', 
           'british', 'flight', 'flights', 'airways', 
           'ryanair', 'airline', 'flying')

# Read in Data, clean & organize.  Wrapped in another function for you!
# No qdap? Go to the directly to ZZZ Supporting" & remove  contraction in clean corpus
textA <- cleanMatrix(pth             = 'BritishAirways.csv',
                     columnName      = 'text',
                     collapse        = T, 
                     customStopwords = stops,
                     type = 'TDM', # TDM or DTM
                     wgt = 'weightTf') # weightTfIdf or weightTf

textB <- cleanMatrix(pth        = 'RyanAir.csv',
                     columnName = 'text',
                     collapse   = T,
                     customStopwords = stops,
                     type = 'TDM', # TDM or DTM
                     wgt = 'weightTf')

df        <- merge(textA, textB, by ='row.names')
names(df) <- c('terms', 'britishAir', 'ryanAir')

# Examine
df[6:10,]

# Calculate the absolute differences among in common terms
df$diff <- abs(df$britishAir - df$ryanAir)

# Organize df for plotting
df<- df[order(df$diff, decreasing=TRUE), ]
top35 <- df[1:35, ]

# Pyarmid Plot
pyramid.plot(lx         = top35$britishAir, #left
             rx         = top35$ryanAir,    #right
             labels     = top35$terms,  #terms
             top.labels = c('britishAir', 'Terms', 'ryanAir'), #corpora
             gap        = 5, # space for terms to be read
             main       = 'Words in Common', # title
             unit       = 'wordFreq') 

# End
