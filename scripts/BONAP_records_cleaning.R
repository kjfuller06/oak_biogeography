library(tidycensus)
library(sf)
library(tidyverse)
library(raster)
library(tmap)
library(tmaptools)

# load layers
counties <- st_read("outputs/counties.shp") %>% 
  dplyr::select(NAME,
                geometry) %>% 
  st_transform(crs = 4326)
# co = unique(counties$NAME)
# write.csv(co, "data/censuscounties.csv")
co = read.csv("data/censuscounties.csv")
bonap = read.csv("data/BONAP range maps/BONAP.csv")
bonap = bonap %>% 
  left_join(co[,c(1,3,5)], by = c("state2" = "State",
                       "County" = "Short"))

records = read.csv("outputs/all_recordsV.1.csv")
records = records %>% 
  st_as_sf(coords = c(lon = "lon", lat = "lat"), crs = 4326)

# remove all points that fall outside BONAP's distribution maps for each species
# Q. chapmanii ####
chap_counties = bonap %>% 
  filter(Scientific.Name == "Quercus chapmanii")
chap_map = counties %>% 
  filter(NAME %in% chap_counties$All)
chap_rec = records[records$species == "Quercus chapmanii",]
chap = chap_rec[chap_map, , join = st_intersects]


# Q. geminata ####
gem_counties = bonap %>% 
  filter(Scientific.Name == "Quercus geminata")
gem_map = counties %>% 
  filter(NAME %in% gem_counties$All)
gem_rec = records[records$species == "Quercus geminata",]
gem = gem_rec[gem_map, , join = st_intersects]

# Q. hemisphaerica ####
hem_counties = bonap %>% 
  filter(Scientific.Name == "Quercus hemisphaerica")
hem_map = counties %>% 
  filter(NAME %in% hem_counties$All)
hem_rec = records[records$species == "Quercus hemisphaerica",]
hem = hem_rec[hem_map, , join = st_intersects]

# Q. margarettae ####
mar_counties = bonap %>% 
  filter(Scientific.Name == "Quercus margarettae")
mar_map = counties %>% 
  filter(NAME %in% mar_counties$All)
mar_rec = records[records$species == "Quercus margarettae",]
mar = mar_rec[mar_map, , join = st_intersects]

# Q. michauxii ####
mic_counties = bonap %>% 
  filter(Scientific.Name == "Quercus michauxii")
mic_map = counties %>% 
  filter(NAME %in% mic_counties$All)
mic_rec = records[records$species == "Quercus michauxii",]
mic = mic_rec[mic_map, , join = st_intersects]

# Q. phellos ####
phe_counties = bonap %>% 
  filter(Scientific.Name == "Quercus phellos")
phe_map = counties %>% 
  filter(NAME %in% phe_counties$All)
phe_rec = records[records$species == "Quercus phellos",]
phe = phe_rec[phe_map, , join = st_intersects]

# Q. shumardii ####
shu_counties = bonap %>% 
  filter(Scientific.Name == "Quercus shumardii")
shu_map = counties %>% 
  filter(NAME %in% shu_counties$All)
shu_rec = records[records$species == "Quercus shumardii",]
shu = shu_rec[shu_map, , join = st_intersects]

# Q. stellata ####
ste_counties = bonap %>% 
  filter(Scientific.Name == "Quercus stellata")
ste_map = counties %>% 
  filter(NAME %in% ste_counties$All)
ste_rec = records[records$species == "Quercus stellata",]
ste = ste_rec[ste_map, , join = st_intersects]

# Q. velutina ####
vel_counties = bonap %>% 
  filter(Scientific.Name == "Quercus velutina")
vel_map = counties %>% 
  filter(NAME %in% vel_counties$All)
vel_rec = records[records$species == "Quercus velutina",]
vel = vel_rec[vel_map, , join = st_intersects]

# Q. virginiana ####
vir_counties = bonap %>% 
  filter(Scientific.Name == "Quercus virginiana")
vir_map = counties %>% 
  filter(NAME %in% vir_counties$All)
vir_rec = records[records$species == "Quercus virginiana",]
vir = vir_rec[vir_map, , join = st_intersects]


# write to disk ####
all = rbind(chap, gem, hem, mar, mic, phe, shu, ste, vel, vir)
all_nocoords = all
all_nocoords$lon = st_coordinates(all)[,1]
all_nocoords$lat = st_coordinates(all)[,2]
st_geometry(all_nocoords) = NULL

write_sf(all, "outputs/all_recordsV.1_bonapcleaned.shp")
write.csv(all_nocoords, "outputs/all_recordsV.1_bonapcleaned.csv", row.names = FALSE)
