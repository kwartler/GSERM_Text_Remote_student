#' Rando Corp Governance PDF from the Internet
#' Jenny "Corporate sustainability examination"


# Libs
library(pdftools)
library(qdap)

setwd("~/Desktop/GSERM_Text_Remote_student/customized student info")
# Source: 'http://www.pwc.com/gx/en/corporate-reporting/archive/publications/assets/best-practice-corporate-gov-reporting-dec08.pdf'

# One page of raw text per each vector element
text <- pdf_text(file.choose())
plot(freq_terms(text, stopwords = tm::stopwords("SMART"), top = 35))

# Not quite text but interesting pdf nuance; often tables are stored as XML
pdf_file <- file.path(getwd(), "RDTE_BA_1_FY_2021_PB_RDTE_Vol 1_Budget_Activity_1.pdf")
info <- pdf_info(pdf_file)
text <- pdf_text(pdf_file)

files <- pdf_attachments(pdf_file)
xmlData <- rawToChar(files[[1]]$data)
cat(xmlData) #XML DATA!
cleanXML <-capture.output(cat(xmlData))
writeLines(cleanXML,'extractedXML.xml')

# Parsing XML is a pain but it's possible; in fact you can just open this XML file directly in Excel!
library(xml2)
#https://stackoverflow.com/questions/62835980/parsing-excel-xml-into-r-with-row-index-value
messyXML <- read_xml('extractedXML.xml')
allRows  <- messyXML %>% xml_ns_strip() %>% xml_find_all("//Row")
allCells    <- allRows %>% lapply(xml_children)
indices  <- lapply(allCells, function(x) as.numeric(xml_attr(x, "Index")))
numRow    <- lapply(seq_along(indices), function(i) rep(i, length(indices[[i]])))
contents <- lapply(allCells, xml_text)

df <- do.call(rbind, lapply(seq_along(indices), function(i){
  data.frame(row = numRow[[i]], col = indices[[i]], value = contents[[i]])
}))
head(df)


#' End