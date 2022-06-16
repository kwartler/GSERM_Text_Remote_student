#' Title: Polarity Math
#' Purpose: Other sentiment libraries 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 14, 2022
#'

# WD
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/C_Sentiment_Unsupervised/data")

# Libs
library(sentimentr)
library(lexicon)
library(dplyr)
library(SentimentAnalysis)
library(ggplot2)


# Read in data
txt <- read.csv("new_orleans_airbnb_listings.csv")

# Explore
head(txt)
summary(txt)
barplot(table(txt$neighbourhood_cleansed), las = 2)

# this is a non-qdap wrapper for sentiment from sentimentr
?sentiment
sentResults <- sentiment(text.var = get_sentences(txt$description), 
                         polarity_dt = lexicon::hash_sentiment_jockers_rinker,
                         valence_shifters_dt = lexicon::hash_valence_shifters, 
                         amplifier.weight = 0.8, n.before = 5, n.after = 2)
head(sentResults)

# Let's aggregate by word count
totalWords <- aggregate(word_count ~ element_id, sentResults, sum)

# Since sentiment is adjusted for doc & sentiment length simple sum should be fine
totalSent <- aggregate(sentiment ~ element_id, sentResults, sum)

results <- left_join(totalWords, totalSent)
head(results)

# sometimes author effort and conviction can be seen with longer documents and the result is a "barbell" i.e. super bad and super positive reviews are often longer w/determined authors
plot(results$word_count, results$sentiment)
cor(results$word_count, results$sentiment, use = 'complete.obs')

# What about by a grouping variable like author or meta information
sentGrp <- sentiment_by(text.var = get_sentences(txt$description), 
                        by = txt$neighbourhood_cleansed,
                        polarity_dt = lexicon::hash_sentiment_jockers_rinker,
                        valence_shifters_dt = lexicon::hash_valence_shifters,
                        amplifier.weight = 0.8, n.before = 5, n.after = 2)
head(sentGrp)

# Let's make a cleveland dot plot of the top 15 neighborhoods
ggplot(sentGrp[1:15,], aes(x = word_count, y = reorder(neighbourhood_cleansed, word_count))) +
  geom_segment(aes(yend = reorder(neighbourhood_cleansed, word_count)), 
               xend = 0, colour = "darkgrey") + 
  geom_point(aes(x = word_count, y = reorder(neighbourhood_cleansed, word_count), size = ave_sentiment)) + 
  theme_bw()


#### Takes a long time; so saved a copy of results
# Now let's try SentimentAnalysis, which can also accept a corpus directly
#multipleMethods <- analyzeSentiment(txt$description, 
#                                    language = "english", 
#                                    aggregate = NULL,
#                                    removeStopwords = TRUE,
#                                    stemming = TRUE)
multipleMethods <- readRDS('multipleMethods.rds')
head(multipleMethods)

# Append the grp
results <- cbind(multipleMethods, neighbourhood_cleansed = txt$neighbourhood_cleansed)
head(results)
# Depending on the method you may want to aggregate up now
neighborhoodResults <- results %>% 
  group_by(neighbourhood_cleansed) %>%
  summarise_at(vars(SentimentLM), list(name = mean)) %>% as.data.frame()
head(neighborhoodResults[order(neighborhoodResults$name, decreasing = T),],15)

# End
