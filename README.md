# GSERM Text Mining Course for Remote Participation

**Each day, please perform a `git pull` to get the most up to date files and lessons.**

## Welcome Video
[Welcome to the class video.](https://www.amazon.com/clouddrive/share/wphzBWpcDj3s4N5PzQmZUyq4xCumZtsdKi5FYjBbO0X)

## Recorded Lesson URLS

|Day   | URL   |Topic   |
|---|---|---|
| Monday  | |  Setup, R Basics, String Manipulation, Text Organizations |
| Tuesday  | | Text Mining Visuals   |
| Wednesday  | | Sentiment Analysis, Unsupervised Methods   |
| Thursday  |  | Supervised Methods  |
| Friday  |  | Ethics, Data Sources, Syntactic Parsing & Lemmatization  |

## Lesson Structure
Each day's lesson is contained in the **lesson** folder.  Each individual lesson folder will contain the following files and folders.
 
* slides - A copy of the presentation covered in the recording.  Provided because some students print the slides and begin to take notes.
* `data` sub folder - contains the data we will work through together
* `scripts` - scaffolded scripts to start our lab session
* `HW` - the daily homework will be in this folder.

## Environment Setup

* You *must* install R, R-Studio & Git locally on your laptop or if you have knowledge you can work from a server instance.  (www.rstudio.cloud)[www.rstudio.cloud] is another option but the free tier has significant time limitations. 

- If you encounter any errors during set up don't worry!  Please request technical help from Prof K.  The `qdap` library is usually the trickiest because it requires Java and `rJava`.  So if you get any errors, try removing that from the code below and rerunning.  This will take **a long time**, so if possible please run prior to class, and at a time you don't need your computer ie *at night*.  We will work to resolve any issues prior to class or during Monday's live session.  **the `qdap` library does not work on mac, due to a java path issue which is not always possible to fix.  Therefore, mac users are encouraged to use rstudio.cloud or simply comment out code lines requiring these function.  This will be noted in class if needed, so no worries.**

## R Packages

```
# Easiest Method to run in your console
install.packages('pacman')
pacman::p_load(ggplot2, ggthemes, stringi, hunspell, qdap, spelling, tm, dendextend,
wordcloud, RColorBrewer, wordcloud2, pbapply, plotrix, ggalt, tidytext, textdata, dplyr, radarchart, 
lda, LDAvis, treemap, clue, cluster, fst, skmeans, kmed, text2vec, caret, glmnet, pROC, textcat, 
xml2, stringr, rvest, twitteR, jsonlite, docxtractr, readxl, udpipe, reshape2, openNLP, vtreat, e1071)

# Additionally we will need this package from a different repo
install.packages('openNLPmodels.en', repo= 'http://datacube.wu.ac.at/')

# You can install packages individually such as below if pacman fails.
install.packages('tm')

# Or using base functions use a nested `c()`
install.packages(c("lda", "LDAvis", "treemap"))

```

## Prerequisite Work
*  Read chapter 1 of the book [Text Mining in Practice with R](https://www.amazon.com/Text-Mining-Practice-Ted-Kwartler/dp/1119282012) book.
