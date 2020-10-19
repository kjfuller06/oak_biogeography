library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)
library(prism)
library(rgdal)
library(httr)

# load dataset
records = read_sf("outputs/all_recordsV.1_bonapcleaned.shp")

# yrs = seq(from = 1990, to = 2019, by = 1)
# options(prism.path = "data/prism data/ppt")
# get_prism_annual('ppt', years = yrs, keepZip = TRUE)
# precip_stack = prism_stack(ls_prism_data()[c(1:30),1])
# ^ this doesn't work

# for(i in c(1:365)){
#   url <- paste('https://geoserver.usanpn.org/geoserver/wcs?service=WCS&version=2.0.1&request=GetCoverage&coverageId=gdd:30yr_avg_agdd&SUBSET=elevation(', i ,')&format=geotiff', sep = "")
#   httr::GET(url,httr::write_disk(paste('data/NPN data/agdd', i, '.tif', sep = "")))
# }

