library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)
library(prism)

# load dataset
records = read_sf("outputs/all_recordsV.1_bonapcleaned.shp")

# yrs = seq(from = 1990, to = 2019, by = 1)
# options(prism.path = "data/prism data/ppt")
# get_prism_annual('ppt', years = yrs, keepZip = TRUE)
# precip_stack = prism_stack(ls_prism_data()[c(1:30),1])
# ^ this doesn't work