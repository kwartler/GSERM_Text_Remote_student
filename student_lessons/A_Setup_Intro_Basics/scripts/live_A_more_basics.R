#' Title: More R Basics
#' Purpose: Adding a bit more complextity to our R knowledge
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: June 10, 2021
#' 

# Wd
setwd("~/Desktop/GSERM_Text_Remote_student/student_lessons/A_Setup_Intro_Basics/data")

# Let's read in two data sets
dfOne <- read.csv("amznWarehouses.csv")
dfTwo <- read.csv("targFC.csv")

# Let's create a list from both objects
warehouseFacilities <- list(amzn     = dfOne,
                            target   = dfTwo)

# What is the structure of this new object?  `str` can be used on any object so its useful!
str(warehouseFacilities)

# Review each list element individually
head(warehouseFacilities$amzn)
head(warehouseFacilities[[1]]) #double brackets to refer to a specific list element

# What about exploring a portion of the second list element
tail(warehouseFacilities$amzn$State) # tail function, list, list element, df column name
tail(warehouseFacilities[[1]][,2])
tail(warehouseFacilities$amzn[,2])
tail(warehouseFacilities[[1]]$State)

# Looks like these columns are in common
head(dfOne$state)
head(dfTwo$state)

# Let's apply a loop to do something on each data frame
onlyCA <- list() #first create an empty list
for(i in 1:length(warehouseFacilities)){
  x     <- subset(warehouseFacilities[[i]], warehouseFacilities[[i]]$state == 'California') #subset
  xName <- names(warehouseFacilities)[i] #which retailer
  onlyCA[[xName]] <- x # add the subset element to the empty object
  print(paste('progress is on', i))
}

# now what is the structure?
str(onlyCA)


# Suppose we want to apply a simpler function to each one?
# How many rows are in each element? Apply that function 1 at a time without a loop
# returns a vector
sapply(onlyCA, nrow) # the apply functions are very useful for lists, and data frame operations

# returns a list
lapply(onlyCA, ncol)

# Now let's use some logic operators
# One step at a time:
grepl('Los Angeles', onlyCA$amzn$city)
sum(grepl('Los Angeles', onlyCA$amzn$city))
sum(grepl('Los Angeles', onlyCA$amzn$city))>1

# If statement
if(sum(grepl('Los Angeles', onlyCA$amzn$city))>1) {
  print('found at least one Los Angeles warehouse')
}

# If else
if(sum(grepl('Kathmandu', onlyCA$amzn$city))>1) {
  print('found at least one Kathmandu warehouse')
} else {
  print('no Kathmandu warehouses found')
}

# We don't have to actually print anything and can be more concise.
ifelse(sum(grepl('Kathmandu', onlyCA$amzn$city))>1, 1, 0)

# End