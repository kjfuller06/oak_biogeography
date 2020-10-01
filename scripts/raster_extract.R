library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)

# load Q. margarettiae dataset and extract values from WorldClim rasters

# remove points outside the US
# find ISO3 code for the US
dplyr::filter(ccodes(), NAME %in% "United States")
# load USA polygon
usa = getData(name = "GADM", country = "USA", level = 1, download = TRUE) %>% 
  st_as_sf() %>% 
  dplyr::select(geometry)
# remove stray points
# records4 = st_join(records3, usa, join = st_within, left = FALSE)
# # plot
# ggplot(records4) +
#   geom_sf(data = usa) +
#   geom_sf(aes(color = SPCD))
# ^ this takes too long to compute. Aborted.