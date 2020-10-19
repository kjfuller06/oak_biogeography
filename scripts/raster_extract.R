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

# load prism datasets
prsm_precip = raster("data/PRISM data/ppt/PRISM_ppt_30yr_normal_4kmM2_annual_asc.asc")
res(prsm_precip)
prsm_tmean = raster("data/PRISM data/tmean/PRISM_tmean_30yr_normal_4kmM2_annual_asc.asc")
res(prsm_tmean)
prsm_tmin = raster("data/PRISM data/tmin/PRISM_tmin_30yr_normal_4kmM2_annual_asc.asc")
res(prsm_tmin)
prsm_tmax = raster("data/PRISM data/tmax/PRISM_tmax_30yr_normal_4kmM2_annual_asc.asc")
res(prsm_tmax)
prsm_vpdmax = raster("data/PRISM data/vpdmax/PRISM_vpdmax_30yr_normal_4kmM2_annual_asc.asc")
res(prsm_vpdmax)
prsm_vpdmin = raster("data/PRISM data/vpdmin/PRISM_vpdmin_30yr_normal_4kmM2_annual_asc.asc")
res(prsm_vpdmin)

# load CSGIARCSI datasets
aridity = raster('data/CGIARCSI data/ai_et0/ai_et0.tif')
res(aridity)
PET = raster('data/CGIARCSI data/et0_yr/et0_yr.tif')
res(PET)

# load NPN datasets
agdd = raster('data/NPN data/data.tif')
res(agdd)

# bind env data to records
dat = cbind(records, 
            prism_ppt = extract(prsm_precip, st_coordinates(records)), 
            prism_tavg = extract(prsm_tmean, st_coordinates(records)),
            prism_tmin = extract(prsm_tmin, st_coordinates(records)),
            prism_tmax = extract(prsm_tmax, st_coordinates(records)),
            prism_vpdmin = extract(prsm_vpdmin, st_coordinates(records)),
            prism_vpdmax = extract(prsm_vpdmax, st_coordinates(records)),
            CGIARCSI_aridity = extract(aridity, st_coordinates(records)),
            CGIARCSI_PET = extract(PET, st_coordinates(records)),
            NPN_agdd = extract(agdd, st_coordinates(records)),
            method = 'simple')

# remove geometry for convenience
all_nocoords = dat
all_nocoords$lon = st_coordinates(dat)[,1]
all_nocoords$lat = st_coordinates(dat)[,2]
st_geometry(all_nocoords) = NULL

# write to disk
write.csv(all_nocoords, "outputs/recordsV.1_extractedvaluesV.1.csv")

# now extract each month's data as individual datasets
# last, extract the same values using the county data
# export mean, min, max, median, stdev, quantiles of 0.01, 0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95, 0.99