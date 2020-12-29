#' Title: Make a d3 word cloud
#' Purpose: Use the wordcloud2 lib 
#' Author: Ted Kwartler
#' email: ehk116@gmail.com
#' License: GPL>=3
#' Date: May-25-2020
#'


library(jsonlite)
library(stringr)
library(ggplot2)
library(ggthemes)
options(scipen = 999)
tmp <- list.files(pattern= '.json')

## Add explore lists

for (i in 1:length(tmp)){
  x <- jsonlite::fromJSON(tmp[i])
  dat <-  x$lyricsResponseList$lyrics$lines[[1]]
  csvNam <- gsub('.json','.csv',make.names(tmp[i]))
  write.csv(dat, csvNam, row.names = F)
  
}

tmp<- list.files(pattern='.csv')
wordCountList <- list()
for(i in 1:length(tmp)){
  x <- read.csv(tmp[i])
  wordCount <- str_count(x$text, "\\S+")
  y <- data.frame(x$endTime, cumulativeWords = cumsum(wordCount),
                  song = gsub('.csv','',tmp[i]))
  wordCountList[[gsub('.csv','',tmp[i])]] <- y
}

## summary
## Add avg words in song
## Add avg words in a section using diff between word / end-st
## grep different words to get position
## stricount words
## grepl 


# Get the timeline of a song
allSongs   <- do.call(rbind, wordCountList)

# Get the last values for each song (total songs)
totalWords <- lapply(wordCountList, tail,1)
totalWords <- do.call(rbind, totalWords)

#totalWords <- aggregate(cumulativeWords ~ song, data = allSongs, max)

ggplot(allSongs,  aes(x=x.endTime,
                      y=cumulativeWords, 
                      group=song, color=song)) +
  geom_line(alpha = 0.25) +
  geom_point(data =totalWords, aes(x=x.endTime,
                                   y=cumulativeWords, 
                                   group=song, color=song), size = 2) +
  geom_text(data =totalWords, aes(label=song),
            hjust="inward", vjust ="inward", size = 3) + 
  theme_gdocs() + theme(legend.position = "none")


# End