#' Title: Retailers
#' Purpose: Build a tag cloud experimental
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: May 23-2020
#'

# libs
library(ggplot2)
library(tm)
library(dplyr)

# Set wd
setwd("~/Documents/GSERM_Text_Remote_admin/lessons/B_Basic_Visuals/data")

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  #corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

# Create custom stop words
stops <- c(stopwords('english'), 'carrefour', 'tesco')

# Bring in the two corpora; works with no meta data
retailers <- Corpus(DirSource("polarizedCloud/"))

# Get word counts
# mind the order is the same as is list.files('~/Documents/GSERM_Text_Remote_admin/lessons/B_Basic_Visuals/data/polarizedCloud')
carreCount <- length(unlist(strsplit(content(retailers[[1]]), " ")))
tescoCount <- length(unlist(strsplit(content(retailers[[2]]), " ")))

# Clean & TDM
cleanRetail <- cleanCorpus(retailers, stops)

cleanRetail <-TermDocumentMatrix(cleanRetail)

# Create data frame from TDM
retailDF <- as.data.frame(as.matrix(cleanRetail))
head(retailDF)

# subset and calc diff
retailDF      <- subset(retailDF, retailDF[,1]>0 & retailDF[,2]>0)
retailDF$diff <- retailDF[,1]-retailDF[,2]

# Subset the data into three categories
# Words used mode by Carrefour
carrefourDF <- subset(retailDF, diff > 0) # Said more  by carre
tescoDF     <- subset(retailDF, diff < 0) # Said more by tesco
equalDF     <- subset(retailDF, diff==0)  # Said equally

# This function takes some number as spaces and returns a vertor
# of continuous values for even spacing centered around zero
optimalSpacing <- function(spaces) {
  if(spaces>1) {
    spacing<-1/spaces
    if(spaces%%2 > 0) {
      lim<-spacing*floor(spaces/2)
      return(seq(-lim,lim,spacing))
    }
    else {
      lim<-spacing*(spaces-1)
      return(seq(-lim,lim,spacing*2))
    }
  }
  else {
    return(0)
  }
}

# Example
optimalSpacing(10)

# This gets applied to the table of differences
table(carrefourDF$diff)

# Get spacing for each frequency type
carrSpacing <- sapply(table(carrefourDF$diff), 
                      function(x) optimalSpacing(x))

# Examine so its clear
table(carrefourDF$diff)
carrSpacing[[1]]  # Diff of 1 appears 49 times, we need 49 values centered at 0

# Now apply to other DFs
tessSpacing  <-sapply(table(tescoDF$diff), 
                      function(x) optimalSpacing(x))
equalSpacing <-sapply(table(equalDF$diff), 
                      function(x) optimalSpacing(x))

# Add spacing to data frames

obama.optim<-rep(0,nrow(carrefourDF))
for(n in names(carrSpacing)) {
  obama.optim[which(carrefourDF$diff==as.numeric(n))]<-carrSpacing[[n]]
}
obama.df<-transform(carrefourDF, Spacing=obama.optim)

palin.optim<-rep(0,nrow(tescoDF))
for(n in names(tessSpacing)) {
  palin.optim[which(tescoDF$diff==as.numeric(n))]<-tessSpacing[[n]]
}
palin.df<-transform(tescoDF, Spacing=palin.optim)

equalDF$Spacing<-as.vector(equalSpacing)

### Step 3: Create visualization
topNum <- 20
obama.df <- head(obama.df[order(obama.df$diff, decreasing = T),],topNum)
palin.df <- head(palin.df[order(palin.df$diff, decreasing = T),],topNum)
equalDF <- head(equalDF[order(equalDF$diff, decreasing = T),],topNum)


tucson.cloud <- ggplot(obama.df, aes(x=diff, y=Spacing))+
  geom_text(aes(size=obama.df[,1], 
                label=row.names(obama.df), colour=diff),
            hjust = "inward", vjust = "inward")+
  geom_text(data=palin.df, 
            aes(x=diff, y=Spacing, label=row.names(palin.df), 
                size=palin.df[,1], color=diff),
            hjust = "inward", vjust = "inward")+
  geom_text(data=equalDF, aes(x=diff, y=Spacing, label=row.names(equalDF), size=equalDF[,1], color=diff))+
  scale_size(range=c(3,11), name="Word Frequency")+scale_colour_gradient(low="darkred", high="darkblue", guide="none")+
  scale_x_continuous(breaks=c(min(palin.df$diff),0,max(obama.df$diff)),labels=c("Said More by Palin","Said Equally","Said More by Obama"))+
  scale_y_continuous(breaks=c(0),labels=c(""))+xlab("")+ylab("")+theme_bw()#+
  #theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(), title=element_text("Word Cloud 2.0, Tucson Shooting Speeches (Obama vs. Palin)"))
#ggsave(plot=tucson.cloud,filename="tucson_cloud.png",width=13,height=7)

# End