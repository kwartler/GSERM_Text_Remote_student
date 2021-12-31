# GSERM Text Mining Course for Remote Participation

**Each day, please perform a `git pull` to get the most up to date files and lessons.**

## Welcome Video

* This class session, we will **not** have virtual machines set up so please forgive my mistake in the video.  You will have to install R, R-studio and git locally on your laptop.
[Welcome to the class video.](https://www.amazon.com/clouddrive/share/wphzBWpcDj3s4N5PzQmZUyq4xCumZtsdKi5FYjBbO0X)

## Recorded Lesson URLS

|Day        | URL   |Topic   |
|-----------|-------|---|
| Monday    | * [Setup*: R, R-Studio & git](https://github.com/kwartler/GSERM_Text_Remote_student/blob/master/student_lessons/A_Setup_Intro_Basics/Day1_setup.pptx?raw=true) <br>* [Vid2**](https://www.amazon.com/clouddrive/share/tuyqzJfhcRlrji3kMrKDFxrTx30FNjmMVfOhzcN4lTO)<br> * [Vid3**](https://www.amazon.com/clouddrive/share/xj3My1KxChRCxVBu5P0HPL7FQO2357AKM9SNfKTtIsB)      |  Setup, R Basics, String Manipulation, Text Organizations |
| Tuesday   | [Vid1](https://www.loom.com/share/cd2854b0007c4d8bb5e799a35309227b?sharedAppSource=shared_library) [Vid2](https://www.loom.com/share/41049b2d4a694d899972c98bb0c30989?sharedAppSource=shared_library) [Vid3](https://www.loom.com/share/cb67587d589946668de6867dff3e32a6?sharedAppSource=shared_library)| Text Mining Visuals   |
| Wednesday | [Vid1](https://www.loom.com/share/ba7b4b37174845bd9d8ab337679bf8ae?sharedAppSource=shared_library) [Vid2](https://www.loom.com/share/3da4a384043b4d238e667ff8ae041dda?sharedAppSource=shared_library) [vid3](https://www.loom.com/share/515e473fb1db47a889533e279fa089be?sharedAppSource=shared_library) [Vid4](https://www.loom.com/share/5ad4dbc235d94bc990bfdb7095b23b36?sharedAppSource=shared_library) [Vid5](https://www.loom.com/share/206e30d96573446596a3f7715575bfbf?sharedAppSource=shared_library)       | Sentiment Analysis, Unsupervised Methods   |
| Thursday  |[Vid1](https://www.loom.com/share/e588883cab3b4acdac7ae01b9b23abe2?sharedAppSource=shared_library) [Vid2](https://www.loom.com/share/73afc3f8d48c4e3795d69b4e3217faf4?sharedAppSource=shared_library)  [Vid3](https://www.loom.com/share/19f769d41d294caba7092caa7c3e1420?sharedAppSource=shared_library) [Vid4](https://www.loom.com/share/d777935817ad4b7ba3880611b6e35425)    | Supervised Methods  |
| Friday    | [Vid1](https://www.loom.com/share/7681ddfe78fe4e58a529286d1e878211?sharedAppSource=shared_library) [Vid2](https://www.loom.com/share/e9ad16389d8749a8a3c7ccc28c95cecb?sharedAppSource=shared_library) [Vid3](https://www.loom.com/share/87f954a992e54f8ea46a99fcf52800ad?sharedAppSource=shared_library)       | Ethics, Data Sources, Syntactic Parsing & Lemmatization  |

*video1 has been replaced with a presentation for r, r-studio & git setup.  
**due to an editing error, you will have to download these instead of streaming

## Live Session Vids; will be deleted July 31, 2021
|Day        | Url| 
|-----------|---|
| Monday    | * [1st day](https://harvard.zoom.us/rec/share/sXQWEBALbF628_1qeo60oUttB0pY6Ik02z6nDL9S3KJgkGsxy18nLjfJKXzFlkWB.dS-VFU4xG1agdMW7) |
| Tuesday   | * [2nd day](https://harvard.zoom.us/rec/share/N0ybDCKHVTZnfooAVetz3S4ictZHuL0pB0GvAFTONyyrAbXRVlfQ-WLbfmMpcI4t.zuF83pp_jTbjcQ3e) |
| Wednesday | * [3rd day](https://harvard.zoom.us/rec/share/6jGg3BkpC4L9eVx2qXLVN1HKIczT3JQmsgAqwNBh_4vnRydmpbgXtyVSZ9ThGa-4.ejPsGgOCkmvF1BDs) |
| Thursday  | * [4th day](https://harvard.zoom.us/rec/share/WrEvt15kA4TUpTMvlTH3TuELOtGAvowRtk5tDewT3qE_ZB1DiIDQ0kIbG-03uKlu.qVuse6oM6We3O-73) |
| Friday    | * [5th day](https://harvard.zoom.us/rec/share/qnheppZUE6LPdJ_qHpuIhC_4nCyY_ofxKKqNN80MkwjKMW7FEkiVjIIwauGv_w89.k67z1XmWBRVWPd3e) |





## Lesson Structure
Each day's lesson is contained in the **lesson** folder.  Each individual lesson folder will contain the following files and folders.
 
* slides - A copy of the presentation covered in the recording.  Provided because some students print the slides and take notes.
* `data` sub folder - contains the data we will work through together
* `scripts` - commented scripts to demonstrate the lesson's concepts
* `HW` - the daily homework will be in this folder.

## Environment Setup

* You *must* install R, R-Studio & Git locally on your laptop or if you have require you can work from a server instance with all software.  (www.rstudio.cloud)[www.rstudio.cloud] is another option but the free tier has significant time limitations. Part of day 1 will be devoted to ensuring people's instances work correctly.

- If you encounter any errors during set up don't worry!  Please request technical help from Prof K.  The `qdap` library is usually the trickiest because it requires Java and `rJava`.  So if you get any errors, try removing that from the code below and rerunning.  This will take **a long time**, so if possible please run prior to class, and at a time you don't need your computer ie *at night*.  We will work to resolve any issues prior to class or during Monday's live session.

## R Packages

```
# Easiest Method to run in your console
install.packages('pacman')
pacman::p_load(ggplot2, ggthemes, stringi, hunspell, qdap, spelling, tm, dendextend,
wordcloud, RColorBrewer, wordcloud2, pbapply, plotrix, ggalt, tidytext, textdata, dplyr, radarchart, 
lda, LDAvis, treemap, clue, cluster, fst, skmeans, kmed, text2vec, caret, glmnet, pROC, textcat, 
xml2, stringr, rvest, twitteR, jsonlite, docxtractr, readxl, udpipe, reshape2, openNLP, vtreat, e1071,
lexicon, echarts4r, lsa, yardstick, textreadr, pdftools, tesseract, mgsub, mapproj, ggwordcloud)

# Additionally we will need this package from a different repo
install.packages('openNLPmodels.en', repo= 'http://datacube.wu.ac.at/')

# You can install packages individually such as below if pacman fails.
install.packages('tm')

# Or using base functions use a nested `c()`
install.packages(c("lda", "LDAvis", "treemap"))

```

## Installing rJava (needed for Qdap) on MAC!
For most students these three links have helped them install java, and then make sure R/Rstudio can find it when loading `qdap`.  **Keep in mind, you don't have to install qdap, to earn a good grade** This is more for use of some functions and the `polarity()` function primarily.

* [link1](https://zhiyzuo.github.io/installation-rJava/)
* [link2](https://stackoverflow.com/questions/63830621/installing-rjava-on-macos-catalina-10-15-6)
* [link3](https://fahadusman.com/setup-rjava-on-mac-and-start-using-opennlp/)

Once java is installed this command *from terminal* often resolves the issue:
```
sudo R CMD javareconf
```

If this causes hardship, don't worry!  You can use a server instance instead.


## Homework & Case Due dates

|HW |Covered in Class. |Due    |
|---|------------------|-------|
|HW1|Monday June14     |June15 |
|HW2|Tuesday  June15   |June16 |
|HW3|Wednesday June16  |June17 |
|HW4|Thursday Jan7     |June18 |
|Case|NA               |June27 |

## Prerequisite Work
*  Read chapter 1 of the book [Text Mining in Practice with R](https://www.amazon.com/Text-Mining-Practice-Ted-Kwartler/dp/1119282012) book.

