library(tidycensus)
library(sf)
library(tidyverse)
library(raster)
library(tmap)
library(tmaptools)

# write species layers to disk
counties <- st_read("data/county boundaries/acs_2012_2016_county_us_B27001.shp") %>% 
  dplyr::select(NAME,
                geometry)
records = read.csv("outputs/all_recordsV.1.csv")
records = records %>% 
  st_as_sf(coords = c(lon = "lon", lat = "lat"), crs = 4326)

tmap_mode("view")
tm_shape(counties)+
  tm_polygons()+
  tm_shape(records[records$species == "Quercus chapmanii",])+
  tm_dots()
# Q. chapmanii does not occur in these counties: Liberty Co, FL; Charlotte Co, FL; Glades Co, FL

tmap_mode("view")
tm_shape(counties)+
  tm_polygons()+
  tm_shape(records[records$species == "Quercus geminata",])+
  tm_dots()
# Q. geminata does not occur in these counties: Broward Co, FL; Glades Co, FL; Ware Co, FL; Hancock Co, MS

tmap_mode("view")
tm_shape(counties)+
  tm_polygons()+
  tm_shape(records[records$species == "Quercus margarettae" & records$source == "BISON",])+
  tm_dots()
# Q. margarettae does not occur in these counties: Leon Co, TX; Henderson Co, TX; Smith Co, TX; 

## hold on a minute. BISON has added a bunch of county centroids that got past CoordinateCleaner. Are they all centroids??
### no, not all BISON data are centroids, just a lot of them.