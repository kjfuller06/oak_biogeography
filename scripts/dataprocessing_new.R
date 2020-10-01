library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)
library(tmap)
library(rbison)

# load GBIF data
new = read.table("data/GBIF data/GBIF_all.txt", fill = TRUE, header = TRUE, sep = "\t", colClasses = c(rep("NULL", 63), "factor", rep("NULL", 34), "character", rep("NULL", 33), rep("character", 3), rep("NULL", 68), rep("factor", 2), rep("NULL", 10), "factor", "NULL", rep("factor", 2), rep("NULL", 10), "factor", rep("NULL", 19)), row.names = NULL)

# keep = c("baseisOfRecord", 
#          "eventDate", 
#          "decimalLatitude", 
#          "decimalLongitude", 
#          "coordinateUncertaintyinMeters",
#          "taxonomicStatus",
#          "nomenclaturalStatus",
#          "issue",
#          "hasCoordinate",
#          "hasGeospatialIssue",
#          "species")

# filter by various things
new$eventDate = as.Date(new$eventDate)
new$year = year(new$eventDate)
new = new %>% 
  filter(year > 1988)

new$coordinateUncertaintyInMeters = as.numeric(new$coordinateUncertaintyInMeters)
new = new %>% 
  filter(coordinateUncertaintyInMeters <= 20000)


# BISON data
nom = c("Quercus_chapmanii", "Quercus_geminata", "Quercus_hemisphaerica", "Quercus_margaretta", "Quercus_margarettae_1", "Quercus_margarettiae_1", "Quercus_michauxii_1", "Quercus_michauxii_2", "Quercus_michauxii_3", "Quercus_phellos_1", "Quercus_shumardii_1", "Quercus_stellata_1", "Quercus_stellata_2", "Quercus_stellata_3", "Quercus_velutina_1", "Quercus_velutina_2", "Quercus_velutina_3", "Quercus_virginiana_1")
chap = bison_solr(scientificName = as.character(nom[1]))
chap

chap = st_read(paste("data/BISON data/bison-", nom[1], ".shp", sep = ""))
gem = st_read(paste("data/BISON data/bison-", nom[2], ".shp", sep = ""))
hem = st_read(paste("data/BISON data/bison-", nom[3], ".shp", sep = ""))
mar = st_read(paste("data/BISON data/bison-", nom[4], ".shp", sep = ""))
mar2 = st_read(paste("data/BISON data/bison-", nom[5], ".shp", sep = ""))
mar3 = st_read(paste("data/BISON data/bison-", nom[6], ".shp", sep = ""))
mic = st_read(paste("data/BISON data/bison-", nom[7], ".shp", sep = ""))
mic2 = st_read(paste("data/BISON data/bison-", nom[8], ".shp", sep = ""))
mic3 = st_read(paste("data/BISON data/bison-", nom[9], ".shp", sep = ""))
phe = st_read(paste("data/BISON data/bison-", nom[10], ".shp", sep = ""))
shu = st_read(paste("data/BISON data/bison-", nom[11], ".shp", sep = ""))
ste = st_read(paste("data/BISON data/bison-", nom[12], ".shp", sep = ""))
ste2 = st_read(paste("data/BISON data/bison-", nom[13], ".shp", sep = ""))
ste3 = st_read(paste("data/BISON data/bison-", nom[14], ".shp", sep = ""))
vel = st_read(paste("data/BISON data/bison-", nom[15], ".shp", sep = ""))
vel2 = st_read(paste("data/BISON data/bison-", nom[16], ".shp", sep = ""))
vel3 = st_read(paste("data/BISON data/bison-", nom[17], ".shp", sep = ""))
vir = st_read(paste("data/BISON data/bison-", nom[18], ".shp", sep = ""))

all = rbind(chap, gem, hem, mar, mar2, mar3, mic, mic2, mic3, phe, shu, ste, ste2, ste3, vel, vel2, vel3, vir)
backup = all
all = all %>% 
  filter(eventDate != NaN)
