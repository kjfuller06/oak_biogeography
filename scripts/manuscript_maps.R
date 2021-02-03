library(tidyverse)
library(tmap)
library(ggplot2)
library(sf)
library(spData)
library(ggsn)
spp = st_read("outputs/all_recordsV.1_bonapcleaned.shp")

cities = maps::us.cities %>% 
  dplyr::filter(pop > 50,000)

ggplot() + 
  geom_sf(data = spData::world, col = 1, fill = "ivory") +
  coord_sf(xlim = c(-125,-65), ylim = c(25,50)) +
  geom_point(data = cities, aes(x = long, y = lat), size = 2) +
  ggrepel::geom_text_repel(data = cities, aes(x = long, y = lat, label = name), nudge_y = 1.5, nudge_x = 5)+
  theme_bw() + 
  theme(panel.background = element_rect(fill = "lightblue"),
        axis.text = element_text(size = 11, colour = 1),
        panel.grid = element_line(colour = NA))+
  scale_x_continuous(breaks = c(35,55))+
  scale_y_continuous(breaks = c(-25, 2)) +
  ggsn::scalebar(location = "bottomleft", x.min = 35, x.max = 60,
                 y.min = -30, y.max = 5, dist = 600, dist_unit = "m", transform = FALSE, 
                 model = "WGS84", st.dist = 0.02, st.size = 4)+
  labs(x = NULL, y = NULL)
