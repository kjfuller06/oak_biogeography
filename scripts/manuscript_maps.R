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
spp1 = unique(spp$species)[10]
# set provenance coordinates
b = 0.5
source = data.frame(x = st_coordinates(seeds[seeds$species == spp1,])[,1],
                    y = st_coordinates(seeds[seeds$species == spp1,])[,2])
# define base map
map1 = ggplot() + 
  geom_sf(data = world, col = 1, fill = "ivory") +
  coord_sf(xlim = c(-100,-70), ylim = c(25,46)) +
  geom_sf(data = spp[spp$species == spp1,], size = 1, col = "chartreuse4") +
  coord_sf(xlim = c(-100,-70), ylim = c(25,46)) +
  geom_sf(data = usa, col = 1, fill = NA) +
  coord_sf(xlim = c(-100,-70), ylim = c(25,46)) +
  theme_bw() + 
  geom_point(data = source, aes(x = x+0.5*b, y = y+0.5*b), pch = 25, size = 2, col = "darkgoldenrod1", fill = "darkgoldenrod1") +
  theme(panel.background = element_rect(fill = "lightblue"),
        axis.text = element_text(size = 11, colour = 1),
        panel.grid = element_line(colour = NA))+
  scale_x_continuous(breaks = c(35,55))+
  scale_y_continuous(breaks = c(-25, 2)) +
  ggsn::scalebar(location = "bottomright", x.min = -100, x.max = -70, y.min = 25, y.max = 46, dist = 250, dist_unit = "km", transform = TRUE, model = "WGS84", st.dist = 0.02, st.size = 0.25, border.size = 0.5, st.color = "lightblue2", box.fill = "gray65", box.color = "gray65")+
  labs(x = NULL, y = NULL)

# plot and add custom provenance marker
tiff(file = paste("outputs/",spp1," distribution.tiff",sep=""), width =1150, height = 1000, units = "px", res = 300)
map1 + annotation_custom(grob = marker,
                       xmin = (cities$long-1.3),
                       xmax = (cities$long+1.2),
                       ymin = (cities$lat-0.3),
                       ymax = (cities$lat+1.8))
dev.off()

