library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)

# load tree species occurrence records from the FIA
df = read.table("TREE.csv", sep = ",", colClasses = c("NULL", rep("factor", 9), rep("NULL", 5), "factor", rep("NULL", 191)), header = TRUE)
# load species selection csv from J. Chieppa
choice = read.table("species_info.csv", sep = ",", colClasses = c("factor", rep("NULL", 10)), header = TRUE) %>% 
  drop_na()

# subset dataframe by species selection and remove plot code number column to avoid confusion with species code column
# NOTE: FIA records contain no observations of Q. geminata, Q. hemisphaerica and Q. chapmanii
df1 = subset(df, SPCD %in% choice$FIA.SPCD)

# load plot information from the FIA
plots = read.table("PLOT.csv", sep = ",", colClasses = c(rep("factor", 9), "NULL", "NULL", rep("factor", 3), rep("NULL", 5), rep("factor", 3), rep("NULL", 8), "factor", rep("NULL", 9), "factor", "factor", "NULL", "factor", rep("NULL", 28)), header = TRUE)

# join spatial coordinates to species occurrence records
records = df1 %>% 
  left_join(plots, by = c("PLT_CN" = "CN", "INVYR", "STATECD", "UNITCD", "COUNTYCD", "PLOT"))

# filter joined records for cleaning- irrational dates, re-samplings, inferred data (as opposed to direct observations) and higher intensity samples (assumed to mean these are re-visits of annual inventories for specific purposes, which introduces bias in sampling effort)
records = records %>% 
  dplyr::filter(INVYR != "9999" & PREV_TRE_CN == "" & SAMP_METHOD_CD == 1 & INTENSITY != 2) %>% 
  droplevels()

# ERROR- years like 12372 are showing up as part of summary(records$INVYR) with no corresponding value in the df
# write cleaned records to csv to avoid error
write.csv(records, "merge.csv", row.names = FALSE)
# load dataset back to keep working
records2 = read.csv("merge.csv")

# filter records to include the last 30yrs of sampling and remove more instances of higher intensity sampling (should move this up to previous filter)
records = records2 %>% 
  filter(INVYR > 1989 & INTENSITY != 3)

# convert records to sfc
records3 = records %>% 
  st_as_sf(coords = c("LON", "LAT"), crs = 4326)
# convert species code to factor
records3$SPCD = as.factor(records3$SPCD)

# plot
ggplot() +
  geom_sf(data = records3, aes(color = SPCD))

# remove points outside the US
# find ISO3 code for the US
dplyr::filter(ccodes(), NAME %in% "United States")
# load USA polygon
usa = getData(name = "GADM", country = "USA", level = 1, download = TRUE) %>% 
  st_as_sf() %>% 
  dplyr::select(geometry)
# remove stray points
# records4 = st_join(records3, usa, join = st_within, left = FALSE)
# # plot
# ggplot(records4) +
#   geom_sf(data = usa) +
#   geom_sf(aes(color = SPCD))
# ^ this takes too long to compute. Aborted.

# write first round of filtering for shapefile to disk
st_write(records3, "FIA_records_f1.shp", delete_layer = TRUE)

# take a look at just Q. margarettiae
Q.marg = records3 %>% 
  filter(SPCD == "840") %>% 
  dplyr::select(SPCD, geometry)
# plot
ggplot() +
  geom_sf(data = Q.marg)

# write just Q. margarettiae records to csv for simplified example dataset
st_write(Q.marg, "Q.margarettiae.shp", delete_layer = TRUE)
