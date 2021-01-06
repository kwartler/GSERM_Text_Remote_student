#' Example Interviews Data Collection
#' Erika & Anna:
#' D1 Research Mentions:
#' "Flow & Speed of Conversation
#' Procurement docs and interviews to review
#' 

# libs
library(jsonlite)
library(stringr)
library(plyr)

# Data from automated closed caption; follow the example in E Lesson Folder
# Original Video https://www.youtube.com/watch?v=oJ_ew833y4Q&ab_channel=ocgreatparkcorp'; keep in mind these expire in 12hrs so you will have to redo and update the link.

youtubeCC <- 'https://www.youtube.com/api/timedtext?v=oJ_ew833y4Q&asr_langs=de%2Cen%2Ces%2Cfr%2Cit%2Cja%2Cko%2Cnl%2Cpt%2Cru&caps=asr&exp=xftt&xorp=true&xoaf=5&hl=en&ip=0.0.0.0&ipbits=0&expire=1609883768&sparams=ip%2Cipbits%2Cexpire%2Cv%2Casr_langs%2Ccaps%2Cexp%2Cxorp%2Cxoaf&signature=3F64B06399516BD8A1F526A99406C306871A5A6B.62FD8739BD24054019E4CA28DEED8F107130EDB6&key=yt8&kind=asr&lang=en&fmt=json3&xorb=2&xobt=3&xovt=3'

# get the data from the api
#' @param youtubeURL string for timedtext youtube API
#' @response 'raw' for raw text, 'meta' to retain speech timing, 'both' for both in a list
getYouTubeCC <- function(youtubeURL, response = 'raw'){
  require(jsonlite)
  require(stringr)
  require(plyr)
  dat <- fromJSON(youtubeCC)
  
  if(response=='raw'|response=='both'){
    # Organize
    rawTxt <- lapply(dat$events$segs, "[", 'utf8') 
    rawTxt <- do.call(rbind, rawTxt)
    rawTxt <- gsub('[\r\n]','',rawTxt[,1])
    rawTxt <- rawTxt[nchar(rawTxt) != "0"]
    rawTxt <- str_squish(rawTxt)
    rawTxt <- paste(rawTxt, collapse = ' ')
  }
  if(response=='meta'|response=='both'){
    timedTxt <- lapply(dat$events$segs, "[", 'utf8')
    
    allTxt <- list()
    for (i in 1:length(timedTxt)){
      x <- paste(timedTxt[[i]][,1], collapse ='')
      allTxt[[i]] <- x
    }
    text <-str_replace_all(allTxt, "[\n]" , "")
    textDF <- data.frame(startTime = dat$events$tStartMs/1000,
                         duration  = dat$events$dDurationMs/1000,
                         text = text)
  }
  if(response=='raw'){resp <- rawTxt}
  if(response=='meta'){resp <- textDF}
  if(response=='both'){resp <- list(raw = rawTxt, meta = textDF)}
 return(resp) 
}

# Example
getYouTubeCC(youtubeURL = youtubeCC, response = 'raw')
getYouTubeCC(youtubeURL = youtubeCC, response = 'meta')
x <- getYouTubeCC(youtubeURL = youtubeCC, response = 'both')

## FROM FILE
interview <- readLines('exampleTranscription.txt')

# Fix odd encoding from the site,  empty lines & source
idx <- grep('(Start of Interview)', interview)+1
interview <- interview[idx:length(interview)]
interview <- gsub('�', "'", interview)
interview <- subset(interview, nchar(interview)>0)


# Use Grep to drop the interviewer
justInterviewee <- interview[-grep('Interviewer', interview)]
justInterviewee <- gsub('Interviewee: ', '', justInterviewee)
justInterviewee


# Optionally collapse it into a single body of information for the person
paste(justInterviewee, collapse = ' ')
