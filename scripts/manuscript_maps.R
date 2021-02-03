library(tidyverse)
library(tmap)
library(ggplot2)
library(sf)
library(spData)
library(ggsn)
library(raster)
library(png)
library(grid)
library(RCurl)

# load datasets
spp = st_read("outputs/all_recordsV.1_bonapcleaned.shp")
# load Jacksonville coordinates
cities = maps::us.cities %>% 
  dplyr::filter(name == "Jacksonville FL")
seeds = read.csv("data/seed_provenance.csv")
names(seeds) = c("species", "provenance")
# load and filter counties by seed provenance
counties <- st_read("outputs/counties.shp") %>% 
  st_transform(crs = crs(spp)) %>% 
  dplyr::select(NAME,
                geometry) %>% 
  dplyr::filter(NAME %in% seeds$provenance)

# merge coordinates to seed provenance
seeds = merge(seeds, counties, by.x = "provenance", by.y = "NAME") %>% 
  st_as_sf(crs = crs(spp)) %>% 
  st_centroid()

# load state boundaries
usa = getData("GADM", country = "USA", level = 1) %>% 
  st_as_sf()
# generate coordinates for louisiana centroid and merge to seed provenance
louisiana = st_centroid(usa[usa$NAME_1 == "Louisiana",]) %>% 
  dplyr::select(NAME_1)
louspp = data.frame(species = c("Quercus phellos",
                      "Quercus shumardii",
                      "Quercus stellata"),
                      NAME_1 = "Louisiana")
louisiana = merge(louisiana, louspp)
names(louisiana)[1] = "provenance"
seeds = rbind(seeds, louisiana)

# load country boundaries
world = spData::world %>% 
  st_as_sf()

# load marker shape
marker = readPNG("data/mapmarker.png")
marker = rasterGrob(marker)

# species list- "Quercus chapmanii", "Quercus geminata",   "Quercus hemisphaerica", "Quercus margarettae", "Quercus phellos", "Quercus shumardii", "Quercus stellata", "Quercus velutina", "Quercus virginiana"
# not used- "Quercus michauxii" 
# set species
spp1 = "Quercus margarettae"
# set provenance coordinates
b = 1.2
x = st_coordinates(seeds[seeds$species == spp1,])[,1]
y = st_coordinates(seeds[seeds$species == spp1,])[,2]
# define base map
map1 = ggplot() + 
  geom_sf(data = world, col = 1, fill = "ivory") +
  coord_sf(xlim = c(-125,-65), ylim = c(25,50)) +
  geom_sf(data = spp[spp$species == spp1,], size = 1, col = "chartreuse4") +
  coord_sf(xlim = c(-125,-65), ylim = c(25,50)) +
  geom_sf(data = usa, col = 1, fill = NA) +
  coord_sf(xlim = c(-125,-65), ylim = c(25,50)) +
  ggrepel::geom_text_repel(data = cities, aes(x = long, y = lat, label = name), nudge_y = 1, nudge_x = 5)+
  theme_bw() + 
  theme(panel.background = element_rect(fill = "lightblue"),
        axis.text = element_text(size = 11, colour = 1),
        panel.grid = element_line(colour = NA))+
  scale_x_continuous(breaks = c(35,55))+
  scale_y_continuous(breaks = c(-25, 2)) +
  ggsn::scalebar(location = "bottomleft", x.min = -125, x.max = -65, y.min = 25, y.max = 50, dist = 1000, dist_unit = "km", transform = TRUE, model = "WGS84", st.dist = 0.02, st.size = 4)+
  labs(x = NULL, y = NULL) +
  ggtitle(spp1) 

# plot and add custom provenance marker
tiff(file = paste("outputs/",spp1," distribution.tiff",sep=""), width =2000, height = 1000, units = "px", res = 200)
map1 + annotation_custom(grob = marker,
                       xmin = (x-b),
                       xmax = (x+b),
                       ymin = (y-0.5*b),
                       ymax = (y+1.5*b))
dev.off()
