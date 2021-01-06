#' Minh "acquisitions and company announcements
#' 

# Lib
library(rvest)

# Query
searchQ <- 'acquisition'
savePth <- '~/Desktop/' # remember the trailing slash!
testing <- T

# Initialize
pg <- read_html('https://www.prnewswire.com/search/news/?keyword=acquisition&page=1&pagesize=100')
totalResults <- pg %>% html_nodes('.alert-muted') %>% html_text()
totalResults <- lapply(strsplit(totalResults, '\nof '), tail, 1)
totalResults <- as.numeric(gsub('\\D+','', totalResults))

# Total Pages; they stop providing info at 99pgs*100 results  despite having tens of thousands :(
if(testing==T){
  totalPgs <- 15
} else {
  totalPgs <- ifelse(totalResults >9900,9900,totalResults)
}


parsedPR <- list()
for(i in 1:totalPgs){
  cat(paste('getting:',i))
  pg <- read_html(paste0('https://www.prnewswire.com/search/news/?keyword=',searchQ,
                         '&page=',i,'&pagesize=1'))
  prURL <- paste0('https://www.prnewswire.com',
                  pg %>% html_nodes('.news-release')  %>% html_attr("href"))
  prHeadline <- pg %>% html_nodes('.news-release') %>% html_text()
  prCard <- pg %>% html_nodes('.card')   %>% html_nodes("*") %>% 
    html_attr("class") %>% 
    unique()
  cat('...')
  txt <- pg %>% html_nodes('.card') %>% html_text()
  txt <- gsub('\n','',txt)
  txt <- subset(txt, nchar(txt)>0)
  txt <- paste(unique(txt), collapse = ' ')
  namedEntity <- unlist(lapply(strsplit(txt, 'More news about: '),tail, 1))
  ifelse(nchar(namedEntity)==0, ner <- NULL, ner <- namedEntity)
  cat('.sleeping 1 sec\n')
  Sys.sleep(1)
  parsedPR[[i]] <- data.frame(prURL       = prURL,
                              prHeadline  = prHeadline,
                              headlineTxt = txt, 
                              namedEntity = ner)
}
parsedPR <- do.call(rbind, parsedPR)

# Append the entire txt
allInfo <- list()
for(i in 1:nrow(parsedPR)){
  cat(paste('getting:',i, 'of', nrow(parsedPR)))
  pg <- read_html(parsedPR$prURL[i])
  completeTxt  <- pg %>% html_node('.release-body') %>% html_text()
  timestamp    <- pg %>% html_node('.mb-no') %>% html_text()
  newsProvider <- paste0('https://www.prnewswire.com',
                         pg %>% 
                           html_nodes(xpath = '//*[@id="main"]/article/header/div[3]/div[1]/a') %>%
                           html_attr("href"))
  
  resp <- data.frame(source = parsedPR$prURL[i],
                     timestamp,
                     newsProvider,
                     parsedPR$prHeadline[i],
                     parsedPR$headlineTxt[i],
                     completeTxt)
  allInfo[[i]] <- resp
  cat('...sleeping 1 sec\n')
  Sys.sleep(1)
}
allInfo <- do.call(rbind, allInfo)
nam <- paste0('allPRs for term',searchQ, ' captured ',Sys.time(),'.csv')
write.csv(allInfo, paste0(savePth, nam), row.names = F) # could also use fst for large data

# End