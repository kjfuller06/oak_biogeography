library(sf)
library(tidyverse)

herb = read.csv("outputs/cleaned_GBIF_BISON_recordsV.1.csv")
FIA = read.csv("data/FIA data/FIA_selection_filtered.csv")
FIA$species = as.factor(FIA$species)
levels(FIA$species) = c("Quercus margarettiae",
                        "Quercus michauxii",
                        "Quercus phellos",
                        "Quercus shumardii",   
                        "Quercus stellata",
                        "Quercus velutina",
                        "Quercus virginiana")
FIA$source = "FIA"
FIA = FIA %>% 
  dplyr::select(-spp_shr)
names(FIA)[c(1:3)] = c("year","lat", "lon")

all = rbind(FIA, herb)

# remove some stray points
all = all %>% 
  filter(lon < -50)
# remove duplicates
all = unique(all)

# remove records from 2020 AGAIN
all = all %>% 
  filter(year != 2020)

map = all %>% 
  st_as_sf(coords = c(lon = "lon",
                      lat = "lat"),
           crs = 4326) %>% 
  st_transform(crs = 3083)

# load counties for county centroid check
counties <- st_read("data/county boundaries/acs_2012_2016_county_us_B27001.shp")
counties = counties[-c(grep("Alaska", counties$NAME),grep("Hawaii", counties$NAME)),]
counties = counties %>% 
  st_transform(crs = 3083)
# calculate the centroids and reproject to a projected crs for accurate distance calculations. Create a buffer of 100m around each centroid
centroids = st_centroid(counties) %>% 
  dplyr::select(NAME,
                geometry) %>% 
  st_buffer(dist = 100)

# check if any records intersect with a 100m buffered county centroid layer
map$ID = c(1:nrow(map))
issues = st_join(centroids, map, left = FALSE)
# tmap_mode("view")
# tm_shape(counties)+tm_borders()+tm_shape(issues)+tm_dots()

# remove issue points
map = map[!c(map$ID %in% issues$ID),]
all = map %>% 
  st_transform(4326)
all$lon = st_coordinates(all)[,1]
all$lat = st_coordinates(all)[,2]
all = st_set_geometry(all, NULL)

# write to disk
write.csv(all, "outputs/all_recordsV.1.csv", row.names = FALSE)
write_sf(map, "outputs/all_recordsV.1.shp")
write_sf(counties, "outputs/counties.shp")
