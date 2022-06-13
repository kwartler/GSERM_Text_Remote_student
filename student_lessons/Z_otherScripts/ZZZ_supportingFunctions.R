# Supporting Functions for script starting Tuesday "G"

tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  #corpus <- tm_map(corpus, content_transformer(qdap::replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

cleanMatrix <- function(pth, columnName, collapse = F, customStopwords, 
                        type, wgt){

  print(type)
  
  if(grepl('.csv', pth, ignore.case = T)==T){
    print('reading in csv')
    text      <- read.csv(pth)
    text      <- text[,columnName]
  }
  if(grepl('.fst', pth)==T){
    print('reading in fst')
    text      <- fst::read_fst(pth)
    text      <- text[,columnName]
  } 
  if(grepl('csv|fst', pth, ignore.case = T)==F){
    stop('the specified path is not a csv or fst')
  }
 
  
  if(collapse == T){
    text <- paste(text, collapse = ' ')
  }
  
  print('cleaning text')
  txtCorpus <- VCorpus(VectorSource(text))
  txtCorpus <- cleanCorpus(txtCorpus, customStopwords)
  
  if(type =='TDM'){
    if(wgt == 'weightTfIdf'){
      termMatrix    <- TermDocumentMatrix(txtCorpus, 
                                      control = list(weighting = weightTfIdf))
    } else {
      termMatrix   <- TermDocumentMatrix(txtCorpus)
      }
    
    response  <- as.matrix(termMatrix)
  } 
  if(type =='DTM'){
    if(wgt == 'weightTfIdf'){
      termMatrix   <- DocumentTermMatrix(txtCorpus, 
                                      control = list(weighting = weightTfIdf))
    } else {
      termMatrix    <- DocumentTermMatrix(txtCorpus)
    }
    response  <- as.matrix(termMatrix)
  if(grepl('dtm|tdm', type, ignore.case=T) == F){
    stop('type needs to be either TDM or DTM')
  }
  
 
  }
  print('complete!')
  return(response)
}

