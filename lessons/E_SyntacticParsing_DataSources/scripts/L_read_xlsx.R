#' Title: xlsx Data
#' Purpose: Extract xlsx data
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: May-25-2020
#'

# Libraries
library(readxl)

# RCloud has small instances so clean out mem for example
rm(list = ls())

# wd
setwd("/cloud/project/StudentLessonPlans/E_Friday/data")

# File Path
filePath <- 'exampleExcel.xlsx'

# Identify sheets
numSheets <- excel_sheets(filePath)
numSheets

# Get individual sheets
sheetOne   <- read_excel(filePath, 1)
sheetTwo   <- read_excel(filePath, 2)
sheetThree <- read_excel(filePath, 3)

# End