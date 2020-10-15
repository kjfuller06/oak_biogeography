library(tidycensus)
library(sf)
library(tidyverse)
library(raster)
library(tmap)
library(tmaptools)

# load layers
counties <- st_read("outputs/counties.shp") %>% 
  dplyr::select(NAME,
                geometry)
records = read.csv("outputs/all_recordsV.1.csv")
records = records %>% 
  st_as_sf(coords = c(lon = "lon", lat = "lat"), crs = 4326)

# remove all points that fall outside BONAP's distribution maps for each species
# Q. chapmanii ####
chap_map = read_sf("outputs/Qchap_bonap.shp")
chap_rec = records[records$species == "Quercus chapmanii",]
chap = chap_rec[chap_map, , join = st_intersects]
# tm_shape(chap_map)+tm_borders()+tm_shape(chap)+tm_dots()

# Q. geminata ####
gem_map = read_sf("outputs/Qgem_bonap.shp")
gem_rec = records[records$species == "Quercus geminata",]
gem = gem_rec[gem_map, , join = st_intersects]
# tm_shape(gem_map)+tm_borders()+tm_shape(gem)+tm_dots()

# Q. hemisphaerica ####
hem_map = read_sf("outputs/Qhem_bonap.shp")
hem_rec = records[records$species == "Quercus hemisphaerica",]
hem = hem_rec[hem_map, , join = st_intersects]
# tm_shape(hem_map)+tm_borders()+tm_shape(hem)+tm_dots()

# Q. margarettae ####
mar_map = read_sf("outputs/Qmar_bonap.shp")
mar_rec = records[records$species == "Quercus margarettae",]
mar = mar_rec[mar_map, , join = st_intersects]
# tm_shape(mar_map)+tm_borders()+tm_shape(mar)+tm_dots()

# Q. michauxii ####
mic_map = read_sf("outputs/Qmic_bonap.shp")
mic_rec = records[records$species == "Quercus michauxii",]
mic = mic_rec[mic_map, , join = st_intersects]
# tm_shape(mic_map)+tm_borders()+tm_shape(mic)+tm_dots()

# Q. phellos ####
phe_map = read_sf("outputs/Qphe_bonap.shp")
phe_rec = records[records$species == "Quercus phellos",]
phe = phe_rec[phe_map, , join = st_intersects]
# tm_shape(phe_map)+tm_borders()+tm_shape(phe)+tm_dots()

# Q. shumardii ####
shu_map = read_sf("outputs/Qshu_bonap.shp")
shu_rec = records[records$species == "Quercus shumardii",]
shu = shu_rec[shu_map, , join = st_intersects]
# tm_shape(shu_map)+tm_borders()+tm_shape(shu)+tm_dots()

# Q. stellata ####
ste_map = read_sf("outputs/Qste_bonap.shp")
ste_rec = records[records$species == "Quercus stellata",]
ste = ste_rec[ste_map, , join = st_intersects]
# tm_shape(ste_map)+tm_borders()+tm_shape(ste)+tm_dots()

# Q. velutina ####
vel_map = read_sf("outputs/Qvel_bonap.shp")
vel_rec = records[records$species == "Quercus velutina",]
vel = vel_rec[vel_map, , join = st_intersects]
# tm_shape(vel_map)+tm_borders()+tm_shape(vel)+tm_dots()

# Q. virginiana ####
vir_map = read_sf("outputs/Qvir_bonap.shp")
vir_rec = records[records$species == "Quercus virginiana",]
vir = vir_rec[vir_map, , join = st_intersects]
# tm_shape(vir_map)+tm_borders()+tm_shape(vir)+tm_dots()


# write to disk ####
all = rbind(chap, gem, hem, mar, mic, phe, shu, ste, vel, vir)
all_nocoords = all
all_nocoords$lon = st_coordinates(all)[,1]
all_nocoords$lat = st_coordinates(all)[,2]
st_geometry(all_nocoords) = NULL

write_sf(all, "outputs/all_recordsV.1_bonapcleaned.shp")
write.csv(all_nocoords, "outputs/all_recordsV.1_bonapcleaned.csv", row.names = FALSE)
