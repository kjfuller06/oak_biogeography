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
  dplyr::select(-INVYR,
                -spp_shr)
names(FIA)[c(1:2)] = c("lat", "lon")

all = rbind(FIA, herb)

# remove some stray points
all = all %>% 
  filter(lon < -50)
# remove duplicates
all = unique(all)

map = all %>% 
  st_as_sf(coords = c(lon = "lon",
                      lat = "lat"),
           crs = 4326)

# write to disk
write.csv(all, "outputs/all_recordsV.1.csv", row.names = FALSE)
write_sf(map, "outputs/all_recordsV.1.shp")
