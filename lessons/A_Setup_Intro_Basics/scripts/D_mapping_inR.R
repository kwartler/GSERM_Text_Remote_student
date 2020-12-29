#' Author: Ted Kwartler
#' Title: Mapping in R
#' Purpose: Load geospatial data and visualize it
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Dec 28 2020
#'

## Set the working directory
setwd("~/Desktop/GSERM_Text_Remote_student/lessons/A_Setup_Intro_Basics/data")

# Libs
library(maps)
library(ggthemes)
library(ggplot2)
library(leaflet)
library(mapproj)

# Import
amzn       <- read.csv('amznWarehouses.csv')

# This is messy webscraped data, check out the state.
tail(amzn$STATE,25)

# Let's clean this up with string manipulation!
amzn$STATE <- gsub('location_','',amzn$STATE)
amzn$STATE <- trimws(amzn$STATE, which='both')
tail(amzn$STATE,25)


# Subset to New England
NEwarehouses <- amzn[ amzn$STATE  %in% c("MA","ME", "VT", "NH"), ]

# A basic map library
map()
map('usa')	# national boundaries
map("state", interior = FALSE)
map("state", interior = T)
map('county', 'new jersey') # reminder clear graphics device
map('state', region = c('mass', 'maine', 'vermont', 'new hampshire'))
points(NEwarehouses$lon,NEwarehouses$lat, col='red')

# More familiar ggplot interface
us <- fortify(map_data('state'), region = 'region')
gg <- ggplot() + 
  geom_map(data  =  us, map = us,
              aes(x = long, y = lat, map_id = region, group = group), fill = 'white', color = 'black', size = 0.25) + 
  coord_map('albers', lat0 = 39, lat1 = 45) +
  theme_map()
gg

# Examine the map data
head(us)

# Subset to multiple states
ne <- us[ us$region %in% c("massachusetts","maine", "vermont", "new hampshire"), ]
ggNE <- ggplot() + 
  geom_map(data  =  ne, map = ne,
           aes(x = long, y = lat, 
               map_id = region, group = group), 
           fill = 'white', color = 'black', size = 0.25) + 
  coord_map('albers', lat0 = 39, lat1 = 45) +
  theme_map()
ggNE +
  geom_point(data=NEwarehouses, 
             aes(x=lon, y=lat), color='red', alpha=0.5) 

# County and single state
ma       <- subset(us, us$region=='massachusetts')
counties <- map_data("county")
MAcounty <- subset(counties, region == "massachusetts")
onlyMA   <- subset(NEwarehouses,NEwarehouses$stateAbb=='MA')

# State and county outlines
ggMA <- ggplot() + 
  geom_map(data  =  MAcounty, map = MAcounty,
           aes(x = long, y = lat, 
               map_id = region, group = group), 
           fill = 'white', color = 'blue', size = 0.25) + 
  coord_map('albers', lat0 = 39, lat1 = 45) +
  theme_map()
ggMA +
  geom_point(data = onlyMA, 
             aes(x = lon, y = lat), color = 'red', alpha=0.5) 

# Leaflet layers using %>% pipe
mplot<- leaflet(data=onlyMA) %>%
  addTiles() %>%
  addMarkers( popup = paste("Loc:", onlyMA$Location, "<br>",
                            "SqFt:", onlyMA$Sq..Feet,"<br>",
                            "Type:", onlyMA$Type)) 
mplot

# End
