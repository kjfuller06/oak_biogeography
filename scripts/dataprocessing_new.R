library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)
library(rnaturalearthdata)
library(tmap)
library(rbison)
library(CoordinateCleaner)

# load GBIF data
GBIF = read.table("data/GBIF data/GBIF_all.txt", fill = TRUE, header = TRUE, sep = "\t", colClasses = c(rep("NULL", 63), "factor", rep("NULL", 34), "character", rep("NULL", 33), rep("character", 3), rep("NULL", 68), rep("factor", 2), rep("NULL", 10), "factor", "NULL", rep("factor", 2), rep("NULL", 10), "factor", rep("NULL", 19)), row.names = NULL)

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
GBIF$eventDate = as.Date(GBIF$eventDate)
GBIF$year = year(GBIF$eventDate)
GBIF = GBIF %>% 
  filter(year > 1988)

GBIF$coordinateUncertaintyInMeters = as.numeric(GBIF$coordinateUncertaintyInMeters)
GBIF = GBIF %>% 
  filter(coordinateUncertaintyInMeters <= 20000 | is.na(coordinateUncertaintyInMeters) == TRUE & hasCoordinate == "true" & hasGeospatialIssues != "true")
GBIF$species[GBIF$species == "Quercus margaretta"] = "Quercus margarettae"
GBIF = GBIF %>% 
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

# BISON data
nom = c("Quercus_chapmanii", "Quercus_geminata", "Quercus_hemisphaerica", "Quercus_margaretta", "Quercus_margarettae_1", "Quercus_margarettiae_1", "Quercus_michauxii_1", "Quercus_michauxii_2", "Quercus_michauxii_3", "Quercus_phellos_1", "Quercus_shumardii_1", "Quercus_stellata_1", "Quercus_stellata_2", "Quercus_stellata_3", "Quercus_velutina_1", "Quercus_velutina_2", "Quercus_velutina_3", "Quercus_virginiana_1")
# chap = bison_solr(scientificName = as.character(nom[1]))
# chap

chap = st_read(paste("data/BISON data/bison-", nom[1], ".shp", sep = ""))
gem = st_read(paste("data/BISON data/bison-", nom[2], ".shp", sep = ""))
hem = st_read(paste("data/BISON data/bison-", nom[3], ".shp", sep = ""))
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

all = rbind(chap, gem, hem, mar2, mar3, mic, mic2, mic3, phe, shu, ste, ste2, ste3, vel, vel2, vel3, vir)
BISON = all %>% 
  filter(is.na(year) == FALSE & ITISsciNme != "Quercus michauxii;Quercus montana")
BISON$year = as.numeric(BISON$year)
BISON$centroid = as.factor(BISON$centroid)
BISON = BISON %>% 
  filter(year > 1988 & year < 2021) %>% 
  filter(is.na(centroid) == TRUE)
BISON$ITISsciNme = as.factor(BISON$ITISsciNme)
BISON$coordUncM = substr(BISON$coordUncM, 1, nchar(BISON$coordUncM)-1)
BISON$coordUncM = as.numeric(BISON$coordUncM)
BISON = BISON %>% 
  filter(coordUncM < 20000 | is.na(coordUncM) == TRUE) %>% 
  st_transform(4326)

# reduce df's down for joining
BISON = BISON %>% 
  dplyr::select("ITISsciNme",
                "geometry")
names(BISON)[1] = "species"
GBIF = GBIF %>% 
  dplyr::select("species",
                "geometry")
BISON$source = "BISON"
GBIF$source = "GBIF"

# join datasets
all = rbind(BISON, GBIF)

# convert back to df
backup = all
backup$lon = st_coordinates(backup)[,1]
backup$lat = st_coordinates(backup)[,2]
backup = st_set_geometry(backup, NULL)

# use CoordinateCleaner to clean up erroneous records
backup$ISO = "USA"
backup = clean_coordinates(backup, 
                           lon = "lon",
                           lat = "lat",
                           species = "species",
                           countries = "ISO",
                           country_ref = rnaturalearth:ne_countries(scale = 10),
                           seas_ref = rnaturalearth::ne_download(scale = 10, 
                                                                 type = 'land', 
                                                                 category = 'physical'),
                           seas_scale = 10,
                           tests = c("capitals", 
                                     "centroids", 
                                     "equal", 
                                     "gbif", 
                                     "institutions",
                                     "seas", 
                                     "zeros"),
                           centroids_detail = "both",
                           verbose = TRUE)
# remove all records with failed test results and remove test columns
all = backup %>% 
  filter(.equ == TRUE & .zer == TRUE & .cap == TRUE & .cen == TRUE & .sea == TRUE & .inst == TRUE & .summary == TRUE) %>% 
  dplyr::select("species", 
                "source",
                "lon",
                "lat")
all = as.data.frame(all)

# write species layers to disk
write.csv(all, "outputs/cleaned_GBIF_BISON_recordsV.1.csv", row.names = FALSE)
