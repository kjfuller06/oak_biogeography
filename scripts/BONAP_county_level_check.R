library(tidycensus)
library(sf)
library(tidyverse)
library(raster)
library(tmap)
library(tmaptools)
library(mapedit)
library(mapview)

# lf <- mapview()
# 
# # draw some polygons that we will select later
# drawing <- lf %>%
#   editMap()
# 
# # little easier now with sf
# mapview(drawing$finished)
# 
# # especially easy with selectFeatures
# selectFeatures(drawing$finished)

# load layers
counties <- st_read("outputs/counties.shp") %>% 
  dplyr::select(NAME,
                geometry)

records = read.csv("outputs/all_recordsV.1.csv")
records = records %>% 
  st_as_sf(coords = c(lon = "lon", lat = "lat"), crs = 4326) %>% 
  st_transform(crs = 3083)

# Q. chapmanii ####
# generate county maps from manual copy of BONAP maps
chap_cmn_bonap = selectFeatures(counties)
chap_rare_bonap = selectFeatures(counties)
chap_cmn_bonap$rarity = "common"
chap_rare_bonap$rarity = "rare"
chap_bonap = rbind(chap_cmn_bonap, chap_rare_bonap)
write_sf(chap_bonap, "outputs/Qchap_bonap.shp")

tmap_mode("view")
tm_shape(counties)+
  tm_polygons()+
  tm_shape(records[records$species == "Quercus chapmanii",])+
  tm_dots()
# Q. chapmanii does not occur in these counties: Liberty Co, FL; Charlotte Co, FL; Glades Co, FL

# Q. geminata ####
gem_cmn_bonap = selectFeatures(counties)
# gem_rare_bonap = selectFeatures(counties)
gem_cmn_bonap$rarity = "common"
# gem_rare_bonap$rarity = "rare"
gem_bonap = gem_cmn_bonap
write_sf(gem_bonap, "outputs/Qgem_bonap.shp")

tmap_mode("view")
tm_shape(counties)+
  tm_polygons()+
  tm_shape(records[records$species == "Quercus geminata",])+
  tm_dots()
# Q. geminata does not occur in these counties: Broward Co, FL; Glades Co, FL; Ware Co, FL; Hancock Co, MS

# Q. hemisphaerica ####
# generate county maps from manual copy of BONAP maps
hem_cmn_bonap = selectFeatures(counties)
hem_rare_bonap = selectFeatures(counties)
hem_int_bonap = selectFeatures(counties)
hem_cmn_bonap$rarity = "common"
hem_rare_bonap$rarity = "rare"
hem_int_bonap$rarity = "introduced"
hem_bonap = rbind(hem_cmn_bonap, hem_rare_bonap)
hem_bonap = rbind(hem_bonap, hem_int_bonap)
write_sf(hem_bonap, "outputs/Qhem_bonap.shp")

# Q. margarettae ####
# generate county maps from manual copy of BONAP maps
mar_cmn_bonap = selectFeatures(counties)
mar_rare_bonap = selectFeatures(counties)
mar_cmn_bonap$rarity = "common"
mar_rare_bonap$rarity = "rare"
mar_bonap = rbind(mar_cmn_bonap, mar_rare_bonap)
write_sf(mar_bonap, "outputs/Qmar_bonap.shp")

tmap_mode("view")
tm_shape(counties)+
  tm_polygons()+
  tm_shape(records[records$species == "Quercus margarettae" & records$source == "BISON",])+
  tm_dots()
# Q. margarettae does not occur in these counties: Leon Co, TX; Henderson Co, TX; Smith Co, TX; 

# Q. michauxii ####
# generate county maps from manual copy of BONAP maps
mic_cmn_bonap = selectFeatures(counties)
mic_rare_bonap = selectFeatures(counties)
mic_cmn_bonap$rarity = "common"
mic_rare_bonap$rarity = "rare"
mic_bonap = rbind(mic_cmn_bonap, mic_rare_bonap)
write_sf(mic_bonap, "outputs/Qmic_bonap.shp")

# Q. phellos ####
# generate county maps from manual copy of BONAP maps
phe_cmn_bonap = selectFeatures(counties)
phe_rare_bonap = selectFeatures(counties)
phe_int_bonap = selectFeatures(counties)
phe_cmn_bonap$rarity = "common"
phe_rare_bonap$rarity = "rare"
phe_int_bonap$rarity = "introduced"
phe_bonap = rbind(phe_cmn_bonap, phe_rare_bonap)
phe_bonap = rbind(phe_bonap, phe_int_bonap)
write_sf(phe_bonap, "outputs/Qphe_bonap.shp")

# Q. shumardii ####
# generate county maps from manual copy of BONAP maps
shu_cmn_bonap = selectFeatures(counties)
shu_rare_bonap = selectFeatures(counties)
shu_cmn_bonap$rarity = "common"
shu_rare_bonap$rarity = "rare"
shu_bonap = rbind(shu_cmn_bonap, shu_rare_bonap)
write_sf(shu_bonap, "outputs/Qshu_bonap.shp")

