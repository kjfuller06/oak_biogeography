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
nom = c("Quercus chapmanii", "Quercus geminata", "Quercus hemisphaerica", "Quercus margaretta", "Quercus margarettae", "Quercus margarettiae", "Quercus michauxii", "Quercus phellos", "Quercus shumardii", "Quercus stellata", "Quercus velutina", "Quercus virginiana")
chap = bison_solr(scientificName = as.character(nom[1]))
chap
