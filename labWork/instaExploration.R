#' Author: TK
#' Date Jan 12
#' Purpose: Insta GSERM Lab
#' Goals:
#' H1. The probability of mentioning heat-related words in posts is higher during (sub)heatwaves than in other days.
#' H2. The probability of expressing negative sentiment in posts is higher during (sub)heatwaves than in other days.
#' H3. The probability of expressing negative sentiment in posts is higher when heat-related words appear in the text.

# Libs
library(data.table)
library(lubridate)

# Inputs
tmp <- list.files(path = "~/Desktop", 
                  pattern = '*.csv',
                  full.names = T)
testing <- T

# Load Data
insta <- fread(tmp)

if(testing == T){
  set.seed(1234)
  insta <- insta[sample(1:nrow(insta),10000),]
}

# Data Prep
timeStamp <- as.POSIXct(insta$time_post, origin="1970-01-01")
hour(timeStamp)
minute(timeStamp)

# Custom Functions

# Processing- cleaning, emojis?

# Sample

# Explore

# Modify

# Modify

# Assess

# End