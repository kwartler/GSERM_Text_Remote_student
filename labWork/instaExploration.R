#' Author: TK
#' Date Jan 12
#' Purpose: Insta GSERM Lab
#' Goals:
#' H1. The probability of mentioning heat-related words in posts is higher during heatwaves than in other days.
#' H2. The probability of expressing negative sentiment in posts is higher during heatwaves than in other days.
#' H3. The probability of expressing negative sentiment in posts is higher when heat-related words appear in the text.

# Libs
library(data.table)
library(lubridate)
#library(mgsub)
library(rtweet)
library(qdap) 
library(stringr)
library(pbapply)
library(lexicon)
library(tidytext)
library(tm)
library(dplyr)

# Inputs
tmp <- list.files(path = "~/Desktop", 
                  pattern = '*.csv',
                  full.names = T)
testing <- T

# Load Data
insta <- as.data.frame(fread(tmp, encoding = "Latin-1")) #Latin-1 "UTF-8"

if(testing == T){
  set.seed(1234)
  insta <- insta[sample(1:nrow(insta),1000),]
}

# EDA
str(insta)

##GEO
# With an instagram api credential you can geocode by loc_id or 
# 3rd party reverse geocoding you can get lat/lon from loc_name/loc_city; not doing now though

## Temporal
timeStamp      <- as.POSIXct(insta$time_post, origin="1970-01-01")
insta$hr       <- hour(timeStamp)
insta$min      <- minute(timeStamp)
insta$month    <- month(timeStamp)
insta$day      <- day(timeStamp)
insta$week     <- week(timeStamp)
insta$weekdays <- weekdays(timeStamp)

## Hashtags
hashes <- str_extract_all(insta$caption, "#\\S+")
hashes <- pblapply(hashes, paste, collapse = ',')
insta$hashes <- do.call(rbind, hashes)

# Custom Functions, lexicons, manual labeling as heatwave related
source('~/Desktop/GSERM_Text_Remote_student/student_lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
fakeHotlexicon <- data.frame(term = c('hot', 'sweating', 'sweat','heat','temperature', 'heatwave'), value = rep('heatwave', 6))
insta$fake_one_is_heatWave <- sample(c(1,0), 
                                     nrow(insta), 
                                     replace = T, 
                                     prob = c(.25, .75))
bing <- get_sentiments(lexicon = c("bing"))
afinn <- get_sentiments(lexicon = c("afinn"))
stops <- c(stopwords('english'),'someIntaWords', 'otherInstaWords')

# Data Prep
instaDTM        <- insta[names(insta) %in% c('post_id','caption')]
names(instaDTM) <- c('doc_id', 'text')
instaDTM        <- VCorpus(DataframeSource(instaDTM))
instaDTM        <- cleanCorpus(instaDTM, stops)
instaDTM        <- DocumentTermMatrix(instaDTM)
instaDTMtidy    <- tidy(instaDTM)

## Identify the heatwave related ones - lexicon join
# Perform Inner Join
bingSent <- left_join(instaDTMtidy, bing, by=c('term' = 'word'))
#bingSent
#table(bingSent$sentiment)
afinnSent <- left_join(instaDTMtidy, afinn, by=c('term' = 'word'))
afinnSent
summary(afinnSent$value)
plot(density(afinnSent$value, na.rm = T))

# Group to the doc & join to original data
bingX         <- aggregate(count~sentiment + document,bingSent, sum)
#head(bingX, 30) #B09Rk2pgPfd 
bingX$bingResult <- ifelse(bingX$sentiment=='negative', 
                        bingX$count * -1, 
                        bingX$count)
#head(bingX, 30)
bingX   <- aggregate(bingResult ~ document, bingX, sum)
#head(bingX, 30) #B09Rk2pgPfd 

afinnX  <- aggregate(count~value + document,afinnSent, sum)
#head(afinnX)
afinnX  <- afinnX %>% 
  group_by(document) %>% 
  mutate(afinnResult = sum(count * value)) 
#head(afinnX) # ugly but it's ok for 2hrs of work
afinnX <- afinnX[!duplicated(afinnX$document),]

# Join to original
insta <- left_join(insta, 
                   bingX[c('document', 'bingResult')],
                   by = c('post_id'='document'))
insta$bingResult[is.na(insta$bingResult)] <- 0

insta <- left_join(insta, 
                   afinnX[c('document', 'afinnResult')],
                   by = c('post_id'='document'))
insta$afinnResult[is.na(insta$afinnResult)] <- 0


## Identify the heatwave related ones - another join to the heat lexicon

## Identify the heatwave related ones - model using manual labels
cv.glmnet()
## Review the coefficients for a larger lexicon and review

## Score all the data

## Evaluate correlation between negativity and high probability of heatwave?
## Look for alignment on sentiment analysis with the two lexicons
## Look for alignment on the model and the heat lexicon method
## For records that are negative in two ways and thought to be heat related using two methods then analyze these in particular
## You can intersect with other data like day of week etc.



