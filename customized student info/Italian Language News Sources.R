#' Migrant News 
#' 
#' Silvia from Lux

# libs
library(tidyRSS)

# Inputs
(searchQ <- URLencode('migrazione'))
lang <- 'IT'
newsOrgAPIKey <- 'XXXXXXXXXXXXXXXXXXXX' # Change to your own

rssFeed <- paste0('https://news.google.com/rss/search?q=',
                  searchQ,'&hl=',lang,'&gl=',lang)
x <- tidyfeed(rssFeed)

# You could save it or just drop extra meta
headlines <- data.frame(url  = x$item_link,
                        date  = x$item_pub_date, 
                        txt1 = x$item_description, 
                        txt2 = x$item_title) # duplicative?

# Another one?
y <- tidyfeed('https://www.ansa.it/sito/ansait_rss.xml') # not sure how to add the query parameter since I don't know Italian
glimpse(y)

# Get Italian Srouces from NEws API Org
sources <- fromJSON(paste0('https://newsapi.org/v2/sources?language=',
                           lang,'&apiKey=',newsOrgAPIKey))

# Get "everything" from NewsAPI.org
topHeadlines <- list()
for(i in 1:nrow(sources$sources)){
  print(i)
  newsFeed <- paste0('https://newsapi.org/v2/everything?q=',
                     searchQ,'&sources=',
                     sources$sources$id[i],
                     '&apiKey=',newsOrgAPIKey)
  
  nam <- sources$sources$id[i]
  res <- fromJSON(newsFeed)
  if(res$totalResults==0){
    final <- NULL
  } else {
      final        <- res$articles
      final$id     <- final$source$id
      final$name   <- final$source$name
      final$source <- NULL
    } 
  topHeadlines[[nam]] <- final
}
topHeadlines <- do.call(rbind, topHeadlines)
topHeadlines[1,]

# End