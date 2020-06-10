library(qdap)
library(dplyr)
setwd("/cloud/project/lessons/C_Sentiment_Unsupervised/data/AutoAndElectronics/rec.autos")

tmp <- list.files()[1:5]

fakeMeta <- data.frame(fileName = tmp,
                       date     = c("2020-June-10","2020-June-9","2020-June-8",
                       "2020-June-8","2020-June-10"),
                       source = c('NewsPaperA','NewsPaperB','NewsPaperA','NewsPaperA','NewsPaperB'))

polarList <- list()
for(i in 1:length(tmp)){
  x    <- readLines(tmp[i])
  polX <- polarity(x)
  finalFrame <- data.frame(file= tmp[i],
                           polScore = polX[[2]]$ave.polarity)
  polarList[[tmp[i]]] <- finalFrame
  print(paste('finished file:',tmp[i]))
}

polarList[[1]]

polDF <- do.call(rbind, polarList)


left_join(polDF, fakeMeta, by = c('file'='fileName'))
