#' Title: Rap Songs
#' Purpose: Rate of speech for hip/hop; Build a plot of the rate of change for lyrics
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 13, 2022
#'

# Set wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/B_Basic_Visuals/data/z_rap_songs")

# Options
options(stringsAsFactors = F, scipen = 999)

# libs
library(stringr)
library(ggplot2)
library(ggthemes)
library(pbapply)

# Multiple files as a list
tmp             <- list.files(pattern = '*.csv')
allSongs        <- pblapply(tmp, read.csv)
names(allSongs) <- gsub('csv','', tmp)

# Basic Exploration
allSongs$BEST.ON.EARTH..Bonus...Explicit..by.Russ.feat..BIA.

## Length of each song
allSongs[[1]][,1:2]
songLength <- sapply(allSongs, function(x){ max(x[,1])}) 
#songLength <- round((songLength /1000)/60, 2)
(songLength[1]/1000) / 60 #3min long

## Total words in song
singleWords <- list()
for(i in 1:length(allSongs)){
  print(names(allSongs)[i])
  x <- strsplit(as.character(allSongs[[i]][,3])," ")
  singleWords[[i]] <- data.frame(song = names(allSongs)[i],
                                 totalWords  = length(unlist(x)))
}
singleWords <- do.call(rbind, singleWords)
head(singleWords)

# Find the specific locations of terms with a custom function applied to list
inDocFinder <- function(DF, 
                        colIDX = 3, 
                        keyword, 
                        ignoreCase = T) {
  x <- grep(keyword, DF[,colIDX], ignore.case = ignoreCase)
  return(x)
}
sapply(allSongs, inDocFinder, keyword = '\\bthe\\b')

# How many times for the pattern
mentions <- sapply(allSongs, inDocFinder, keyword = 'money')
sapply(mentions, length)

mentions <- sapply(allSongs, inDocFinder, keyword = 'the')
sapply(mentions, length)

# Or find them at the song level
inSongFinder <- function(DF, colIDX = 3, keyword, ignoreCase = T){
  x <- paste(DF[,colIDX], collapse = ' ')
  x <- grepl(keyword, x, ignore.case = ignoreCase)
  return(x)
}
sapply(allSongs, inSongFinder,keyword = 'money')

# Because the transcript has temporal nature, we want to know cadence
# Calculate the cumulative sum over time
wordCountList <- list()
for(i in 1:length(allSongs)){
  x <- allSongs[[i]]
  wordCount <- str_count(x$text, "\\S+") #count the space character
  #you can also use strplit with a space and then count the length
  y <- data.frame(x$endTime, 
                  cumulativeWords = cumsum(wordCount),
                  song            = names(allSongs[i]))
  names(y)[1] <- 'endTime'
  wordCountList[[i]] <- y
}

# Get the timeline of a song
songTimeline  <- do.call(rbind, wordCountList)
head(songTimeline)

# Get the last values for each song (total words but now with time)
totalWords <- data.frame(song = singleWords$song,
                         endTime = songLength, 
                         cumulativeWords = singleWords$totalWords,
                         row.names = NULL)
head(totalWords)

# Make a plot of the speech cadence
ggplot(songTimeline,  aes(x     = endTime,
                          y     = cumulativeWords, 
                          group = song, 
                          color = song)) +
  geom_line(alpha = 0.25) +
  geom_point(data =totalWords, aes(x     = endTime,
                                   y     = cumulativeWords, 
                                   group = song, 
                                   color = song), size = 2) +
  geom_text(data  = totalWords, aes(label=song),
            hjust = "inward", vjust = "inward", size = 3) + 
  theme_tufte() + theme(legend.position = "none")

# Two clusters, let's see Em vs all
songTimeline$eminem <- grepl('eminem', 
                             songTimeline$song, 
                             ignore.case = T)
totalWords$eminem <- grepl('eminem', 
                           totalWords$song, 
                           ignore.case = T)
ggplot(songTimeline,  aes(x     = endTime,
                          y     = cumulativeWords, 
                          group = song, 
                          color = eminem)) +
  geom_line(alpha = 0.25) +
  geom_point(data =totalWords, aes(x     = endTime,
                                   y     = cumulativeWords, 
                                   group = song, 
                                   color = eminem), size = 2) +
  geom_text(data  = totalWords, aes(label=song),
            hjust = "inward", vjust = "inward", size = 3) + 
  theme_few() + theme(legend.position = "none")


# Fit a linear model to each song and extract the x-coefficient
# Poached: https://stackoverflow.com/questions/40284801/how-to-calculate-the-slopes-of-different-linear-regression-lines-on-multiple-plo
library(tidyr)
library(purrr)
library(dplyr)
doModel  <- function(dat) {lm(cumulativeWords ~ endTime + 0, dat)}
getSlope <- function(mod) {coef(mod)[2]}
models <- songTimeline %>% 
  group_by(song) %>%
  nest %>% #tidyr::Nest Repeated Values In A List-Variable.
  mutate(model = map(data, doModel)) %>% 
  mutate(slope = map(model, coefficients)) 

# Avg words per second by song
wordsSecs <- data.frame(song = names(allSongs),
                        wordsPerSecond= (unlist(models$slope) * 1000)) #adj for milliseconds
wordsSecs[order(wordsSecs$wordsPerSecond, decreasing = T),]

# End