library(dplyr)
library(sf)
library(raster)
library(rgeos)

# load datasets
plots = read.csv("data/FIA data/PLOT.csv", colClasses = c(rep(NA, 9), "NULL", "NULL", NA, NA, NA, rep("NULL", 5), NA, NA, NA, rep("NULL", 8), NA, rep("NULL", 9), NA, NA, "NULL", NA, rep("NULL", 28)))
spp = read.csv("data/species_info.csv")
records=read.csv("data/FIA data/TREE.csv", colClasses = c("NULL", rep(NA, 9), rep("NULL", 5), NA, rep("NULL", 191)))
# keep only the species codes that exist for species of interest (Q. chapmanii is not listed in the FIA database)
SPCDs=spp$FIA.SPCD[1:9]

backup = records
# keep only variables of interest for species of interest
records = records%>%
  filter(SPCD%in%SPCDs)
backup= records
records = unique(records)
backup = records

# join lat/lon coordinates to species records
 = left_join(FL_filtered, plots) %>% 
  dplyr::select("SPCD", "LAT", "LON")
FL_filt_join = left_join(FL_filt_join, spp[,c(1,3)], 
                         by = c("SPCD" = "FIA.SPCD")) %>% 
  dplyr::select(-SPCD)

backup = FL_filt_join
# convert species records to simple feature
FL_filt_join = st_as_sf(FL_filt_join, 
                        coords = c("LON", "LAT"), 
                        crs = 4269)

# get political boundaries for the USA
dplyr::filter(ccodes(), NAME %in% "United States")
poly = getData("GADM", country = "USA", level = 1)
contiguous = st_as_sf(poly) %>% 
  filter(NAME_1 != "Alaska" & NAME_1 != "Hawaii")

# plot to look at distributions (need to change the spatial extent because the US colonised so many islands it's ridiculous)
plot(st_geometry(contiguous), xlim = st_bbox(contiguous)[c(1,3)], ylim = st_bbox(contiguous)[c(2,4)])
plot(st_geometry(FL_filt_join)[1:1000], add = TRUE)
