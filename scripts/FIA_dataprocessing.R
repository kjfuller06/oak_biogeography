library(dplyr)
library(sf)
library(tidyverse)
library(raster)
library(rgeos)
library(CoordinateCleaner)

# load datasets
plots = read.csv("data/FIA data/PLOT.csv", colClasses = c(rep(NA, 9), "NULL", "NULL", NA, NA, NA, rep("NULL", 5), NA, NA, NA, rep("NULL", 8), NA, rep("NULL", 9), NA, NA, "NULL", NA, rep("NULL", 28)))
spp = read.csv("data/species_info.csv")
records=read.csv("data/FIA data/TREE.csv", colClasses = c(rep(NA, 10), rep("NULL", 5), NA, rep("NULL", 191)))
# keep only the species codes that exist for species of interest (Q. chapmanii is not listed in the FIA database)
SPCDs=spp$FIA.SPCD[1:9]
# filter FIA data by selected species codes
records = records%>%
  filter(SPCD%in%SPCDs)
# write selection to disk
write.csv(records, "data/FIA data/FIA_selection.csv", row.names = FALSE)

# filter out any repeated measures trees, keeping only the most recent records
previous = unique(records$PREV_TRE_CN)[-1]
records = subset(records, !(CN %in% previous))

# join lat/lon coordinates to species records
records = left_join(records, plots, by = c("PLT_CN" = "CN", 
                                           "INVYR",
                                           "STATECD",
                                           "UNITCD",
                                           "COUNTYCD",
                                           "PLOT"))
names(spp)[c(2,3)] = c("species", "spp_shr")
records = left_join(records, spp[,c(1:3)], 
                         by = c("SPCD" = "FIA.SPCD"))
records = records %>% 
  dplyr::select(-CN,
                -PLT_CN,
                -PREV_TRE_CN,
                -PLOT,
                -SUBP,
                -TREE,
                -SRV_CN,
                -PREV_PLT_CN,
                -ELEV,
                -SPCD,
                -CTY_CN)

# filter out the rest of the back data
records$MEASYEAR = as.numeric(records$INVYR)
records = records %>% 
  filter(INVYR > 1988 &
           INVYR < 2021 &
           INTENSITY != 3 &
           INTENSITY != 2 &
           (QA_STATUS == 1 | QA_STATUS == 7) &
           SAMP_METHOD_CD == 1 &
           SUBP_EXAMINE_CD == 4)

# use CoordinateCleaner to filter points by various tests
records$ISO = "USA"
records = clean_coordinates(records, 
                           lon = "LON",
                           lat = "LAT",
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
                           verbose = TRUE)
# remove failed observations and test columns
records = records %>% 
  filter(.cap == TRUE & .sea == TRUE & .summary == TRUE) %>% 
  dplyr::select(INVYR,
                LAT,
                LON,
                species,
                spp_shr)

# write filtered selection to disk
write.csv(records, "data/FIA data/FIA_selection_filtered.csv", row.names = FALSE)
