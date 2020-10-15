library(sf)
library(tidyverse)

# load datasets
spp = read.csv("data/species_info.csv")
records=read.csv("data/FIA data/TREE.csv", colClasses = c(rep(NA, 10), rep("NULL", 5), NA, rep("NULL", 191)))
# keep only the species codes that exist for species of interest (Q. chapmanii is not listed in the FIA database)
SPCDs=spp$FIA.SPCD[1:9]
# filter FIA data by selected species codes
records = records%>%
  filter(SPCD%in%SPCDs)
# write selection to disk
write.csv(records, "data/FIA data/FIA_selection.csv", row.names = FALSE)