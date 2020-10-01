library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)

# FIA data ####
# 1. Subset FIA data for species of interest
# 2. Load plot information and join lat-lon coordinates to species observations
# 3. Clean records <--------- need to reaxamine the previous year filter. This means we're only taking the oldest possible record of every tree
#     a. Remove records with irrational years, trees measured in previous years, records that were derived from satellite images rather than directly observed, and surveys with more sampling intensity than the standard annual inventory.
#     b. Data written to file to work around a date error.
#     c. Remove all records except those from 1989 or later (the last 30yrs) and more high intensity surveys.
# 4. Convert to simple feature and plot
# 5. Write shapefile to disk. Select one species to examine data and write this shapefile to disk as well.

# 1 ####
# load tree species occurrence records from the FIA
df = read.table("data/FIA data/TREE.csv", sep = ",", colClasses = c("NULL", rep("factor", 9), rep("NULL", 5), "factor", rep("NULL", 191)), header = TRUE)
# load species selection csv from J. Chieppa
choice = read.table("data/species_info.csv", sep = ",", colClasses = c("factor", rep("NULL", 10)), header = TRUE) %>% 
  drop_na()

# subset dataframe by species selection and remove plot code number column to avoid confusion with species code column
# NOTE: FIA records contain no observations of Q. geminata, Q. hemisphaerica and Q. chapmanii
df1 = subset(df, SPCD %in% choice$FIA.SPCD)

# 2 ####
# load plot information from the FIA
plots = read.table("data/FIA data/PLOT.csv", sep = ",", colClasses = c(rep("factor", 9), "NULL", "NULL", rep("factor", 3), rep("NULL", 5), rep("factor", 3), rep("NULL", 8), "factor", rep("NULL", 9), "factor", "factor", "NULL", "factor", rep("NULL", 28)), header = TRUE)

# join spatial coordinates to species occurrence records
records = df1 %>% 
  left_join(plots, by = c("PLT_CN" = "CN", "INVYR", "STATECD", "UNITCD", "COUNTYCD", "PLOT"))

# 3a ####
# filter joined records for cleaning- irrational dates, re-samplings, inferred data (as opposed to direct observations) and higher intensity samples (assumed to mean these are re-visits of annual inventories for specific purposes, which introduces bias in sampling effort)
records = records %>% 
  dplyr::filter(INVYR != "9999" & PREV_TRE_CN == "" & SAMP_METHOD_CD == 1 & INTENSITY != 2) %>% 
  droplevels()

# 3b ####
# ERROR- years like 12372 are showing up as part of summary(records$INVYR) with no corresponding value in the df
# write cleaned records to csv to avoid error
write.csv(records, "outputs/merge.csv", row.names = FALSE)
# load dataset back to keep working
records2 = read.csv("outputs/merge.csv")

# 3c ####
# filter records to include the last 30yrs of sampling and remove more instances of higher intensity sampling (should move this up to previous filter)
records = records2 %>% 
  filter(INVYR > 1989 & INTENSITY != 3)

# 4 ####
# convert records to sfc
records3 = records %>% 
  st_as_sf(coords = c("LON", "LAT"), crs = 4326)
# convert species code to factor
records3$SPCD = as.factor(records3$SPCD)

# plot
ggplot() +
  geom_sf(data = records3, aes(color = SPCD))

# 5 ####
# write first round of filtering for shapefile to disk
st_write(records3, "outputs/FIA_records_f1.shp", delete_layer = TRUE)

# take a look at just Q. margarettiae
Q.marg = records3 %>% 
  filter(SPCD == "840") %>% 
  dplyr::select(SPCD, geometry)
# plot
ggplot() +
  geom_sf(data = Q.marg)

# write just Q. margarettiae records to csv for simplified example dataset
st_write(Q.marg, "outputs/Q.margarettiae.shp", delete_layer = TRUE)


# BISON data ####
# 1. 

# 1 ####
chap = st_read("data/BISON data/bison-Quercus_chapmanii.shp")
ggplot(chap)+geom_sf()

gem = st_read("data/BISON data/bison-Quercus_geminata.shp")
ggplot(gem)+geom_sf()

hem = st_read("data/BISON data/bison-Quercus_hemisphaerica.shp")
ggplot(hem)+geom_sf()

marg = st_read("outputs/Q.margarettiae.shp")
ggplot(marg)+geom_sf()

ggplot(marg)+
  geom_sf(aes(colour = "red"))+
  geom_sf(data = gem, aes(colour = "blue"))
