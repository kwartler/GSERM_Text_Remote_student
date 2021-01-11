#' Title: Polarity Math
#' Purpose: Learn and calculate polarity 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28, 2020
#'

# Libs
library(qdap)

# Neutral
polarity('neutral neutral neutral')
(0 + 0 + 0)/sqrt(3)

# Amplifier
polarity('neutral very good')
(0 + 0.8 + 1)/sqrt(3)

# De-Amplifier
polarity('neutral barely good')
(-0.8 + 1) /sqrt(3)

# Negation
polarity('neutral not  good')
(-1 *(0 + 1)) / sqrt(3)

# Double Negation
polarity('not not good')
(-1*-1* (1)) / sqrt(3)

# Order doesn't matter in the context cluster
polarity('good not good')
(-1*(1 + 1)) / sqrt(3)

# End