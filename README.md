# GSERM Text Mining Course for Remote Participation

**Each day, please perform a `git pull` to get the most up to date files and lessons.**

## Welcome Video
[Welcome to the class video.](https://www.amazon.com/clouddrive/share/wphzBWpcDj3s4N5PzQmZUyq4xCumZtsdKi5FYjBbO0X)

## Recorded Lesson URLS

|Day   | URL   |Topic   |
|---|---|---|
| Monday  | [vid1](https://www.youtube.com/watch?v=INR9GYTSUHw) [vid2](https://www.youtube.com/watch?v=NsaFGzyiPpY&feature=youtu.be) [vid3](https://youtu.be/VVV2oREz3IE)|  Setup, R Basics, String Manipulation, Text Organizations |
| Tuesday  | [vid1](https://www.loom.com/share/cd2854b0007c4d8bb5e799a35309227b) [vid2](https://www.loom.com/share/41049b2d4a694d899972c98bb0c30989) [vid3](https://www.loom.com/share/cb67587d589946668de6867dff3e32a6) | Text Mining Visuals   |
| Wednesday  | [vid1](https://www.loom.com/share/ba7b4b37174845bd9d8ab337679bf8ae) [vid2](https://www.loom.com/share/3da4a384043b4d238e667ff8ae041dda)  [vid3](https://www.loom.com/share/515e473fb1db47a889533e279fa089be) [vid4](https://www.loom.com/share/5ad4dbc235d94bc990bfdb7095b23b36) [vid5](https://www.loom.com/share/206e30d96573446596a3f7715575bfbf)| Sentiment Analysis, Unsupervised Methods   |
| Thursday  | [vid1](https://www.loom.com/share/e588883cab3b4acdac7ae01b9b23abe2) [vid2](https://www.loom.com/share/73afc3f8d48c4e3795d69b4e3217faf4) [vid3](https://www.loom.com/share/19f769d41d294caba7092caa7c3e1420) [vid4](https://www.loom.com/share/519c8204db4f48a0897116569803f13a) | Supervised Methods  |
| Friday  | TBD   | Ethics, Data Sources, Syntactic Parsing & Lemmatization  |

## Lesson Structure
Each day's lesson is contained in the **lesson** folder.  Each individual lesson folder will contain the following files and folders.
 
* slides - A copy of the presentation covered in the recording.  Provided because some students print the slides and begin to take notes.
* `data` sub folder - contains the data we will work through together
* `scripts` - scaffolded scripts to start our lab session
* `HW` - the daily homework will be in this folder.

## Environment Setup
* The University is providing virtual machines for participants to run R code and perform analysis.  They will be providing that information to you and supporting any technical issues.

* As a backup, a student *could* use  [https://rstudio.cloud](https://rstudio.cloud). 
  * If using this method, please follow the setup instructions [here](https://github.com/kwartler/GSERM_TextMining/blob/master/Rstudio_Cloud_Instructions.docx) to set up a cloud space for programming & connecting to git.  Since you are just setting up, you will need to click "download" from the link to get the word doc directly.  After that files can be delivered through a `git pull`.

* You *can* install R, R-Studio & Git locally on your laptop but any system issues will be yours to resolve.  

- If you encounter any errors during set up don't worry!  Please request technical help from Prof K and the university.  The `qdap` library is usually the trickiest because it requires Java and `rJava`.  So if you get any errors, try removing that from the code below and rerunning.  This will take **a long time**, so if possible please run prior to class, and at a time you don't need your computer ie *at night*.  We will work to resolve any issues prior to class or during Monday's live session.  **the `qdap` library does not work on mac, due to a java path issue.  Therefore, mac users are encouraged to use the univeristy provided virtual machine or rstudio.cloud**

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
