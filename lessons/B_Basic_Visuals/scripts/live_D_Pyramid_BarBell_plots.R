#' Title: Pyramids and barbell plots
#' Purpose: Comparative visualizations for text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: May 23-2020
#'

# Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_student/lessons/B_Basic_Visuals/data")

# Libs
library(tm)
library(qdap)
library(plotrix)
library(ggplot2)
library(ggthemes)
library(ggalt)

# Bring in our supporting functions
source('~/Documents/GSERM_Text_Remote_admin/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

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

##### EXPERIMENTAL #####
# Barbell by relative distance from average among top terms
StdTerm  <- sd(c(top35[,2], top35[,3] )) 
meanTerm <- mean(c(top35[,2], top35[,3] )) 

# Append distances to top35
top35$britDist <- (top35$britishAir - meanTerm) / StdTerm 
top35$ryanDist <- (top35$ryanAir - meanTerm) / StdTerm 

# Munge data frame so the factor is ordered by smallest diff to largest
top35$terms <- as.factor(top35$terms)
top35$terms <- factor(top35$terms, 
                      levels=unique(top35$terms[order(top35$diff)]), 
                      ordered=TRUE)

# Annotations Information
textAnnotations <- data.frame(x = c(-2,0,2),
                              y = c(2,2,2),
                              text = c('less than AVG', 
                                       'AVG', 
                                       'greater than AVG'))
ggplot() +
  geom_segment(data=top35, 
               mapping=aes(x=britDist, y=terms, 
                           xend=ryanDist, yend=terms), 
               size=0.5, color="darkgrey") + 
  geom_point(data=top35, 
             mapping=aes(x=britDist, y=terms, color = 'BritishAir'), 
             size=1.25) + 
  geom_point(data=top35, 
             mapping=aes(x=ryanDist, y=terms, color = 'RyanAir'), 
             size=1.25, fill = "red") +
  theme_few() + 
  geom_vline(xintercept = 0) +
  scale_x_continuous(limits = c(-2, 2)) + 
  theme(axis.title.x=element_blank()) + 
  ggtitle("Relative Word Usage RyanAir/BritishAir") +
  geom_text(data = textAnnotations, 
            aes(x= x, y = y, label = text),
            size = 3,color= 'red',
            vjust = "inward", hjust = "inward")

# End
