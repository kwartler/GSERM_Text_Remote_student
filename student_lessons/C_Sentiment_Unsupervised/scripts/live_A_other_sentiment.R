#' Title: Polarity Math
#' Purpose: Other sentiment libraries 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 14, 2022
#'

# Libs
library(sentimentr)

sentiment(text.var, polarity_dt = lexicon::hash_sentiment_jockers_rinker,
          valence_shifters_dt = lexicon::hash_valence_shifters, 
          amplifier.weight = 0.8, n.before = 5, n.after = 2)


sentiment_by(text.var, by = NULL,polarity_dt = lexicon::hash_sentiment_jockers_rinker,
             valence_shifters_dt = lexicon::hash_valence_shifters,
             amplifier.weight = 0.8, n.before = 5, n.after = 2)