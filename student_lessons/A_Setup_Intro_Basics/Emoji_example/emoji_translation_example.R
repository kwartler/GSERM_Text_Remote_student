
# libs
library(mgsub)
library(pbapply)

# read in the emoji list
emoji <- read.csv('emojis.csv')

# sapply with progress bar, the multiple global sub (mgsub)
subbedTxt <- pbsapply(textVector, mgsub, emoji$emoji, emoji$name)

