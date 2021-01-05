#' VC startup and finance data
#' Lukas

# Libs
library(rvest)
library(pdftools)
library(tabulizer)

# Inputs
setwd("~/Desktop/GSERM_Text_Remote_student/customized student info/tmp")
unicorns <- read_html('https://primeunicornindex.com/unicorn-companies/')
links    <- unicorns %>% html_nodes("a") %>% html_attr("href")
pth      <- 'a0b26548-5bde-4dc3-80c0-95729c3ce3bd'


# Subset to pdf
companyLinks <- links[grep('pdf', links)]

# Download all unicorn financials
for(i in 1:length(companyLinks)){
  print(i)
  nam <- trimws(unlist(lapply(strsplit(companyLinks[i], '/'), tail, 1)),'both')
  download.file(trimws(companyLinks[i]), destfile = nam, mode = "wb")
}

# Let's examine one
tmp <- list.files(pattern = pth)
pdf_file <- file.path(tmp)

# Quick & Dirty
x       <- extract_tables(tmp)
ncolLst <- unique(unlist(lapply(x, ncol)))


consolidatedLst <- list()
for(i in 1:length(ncolLst)){
  print(i)
  y <- x[sapply(x,ncol) == ncolLst[i]]
  consolidatedLst[[i]] <- do.call(rbind, y)
}

# Clean this nonsense
consolidatedLst[[1]]
roundInfo <- consolidatedLst[[1]][grep('Date', consolidatedLst[[1]][,1]),]
valuesInfo <- consolidatedLst[[1]][grep('Date', consolidatedLst[[1]][,1])+1,]

rounds <- data.frame(valuesInfo)
names(rounds) <- make.names(roundInfo[1,])
head(rounds)

# End