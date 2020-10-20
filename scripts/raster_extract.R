# note: redo analysis with resampled and reprojected raster layers
library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)
library(prism)
library(rgdal)
library(httr)
library(tmap)

# load datasets
records = read_sf("outputs/all_recordsV.1_bonapcleaned.shp")

# occurrence records for annual data ####
# load prism datasets
prsm_precip = raster("data/PRISM data/ppt/PRISM_ppt_30yr_normal_4kmM2_annual_asc.asc")
# res(prsm_precip)
prsm_tmean = raster("data/PRISM data/tmean/PRISM_tmean_30yr_normal_4kmM2_annual_asc.asc")
# res(prsm_tmean)
prsm_tmin = raster("data/PRISM data/tmin/PRISM_tmin_30yr_normal_4kmM2_annual_asc.asc")
# res(prsm_tmin)
prsm_tmax = raster("data/PRISM data/tmax/PRISM_tmax_30yr_normal_4kmM2_annual_asc.asc")
# res(prsm_tmax)
prsm_vpdmax = raster("data/PRISM data/vpdmax/PRISM_vpdmax_30yr_normal_4kmM2_annual_asc.asc")
# res(prsm_vpdmax)
prsm_vpdmin = raster("data/PRISM data/vpdmin/PRISM_vpdmin_30yr_normal_4kmM2_annual_asc.asc")
# res(prsm_vpdmin)

# load CSGIARCSI datasets
aridity = raster('data/CGIARCSI data/ai_et0/ai_et0.tif')
# res(aridity)
PET = raster('data/CGIARCSI data/et0_yr/et0_yr.tif')
# res(PET)

# load NPN datasets
agdd = raster('data/NPN data/data.tif')
# res(agdd)

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
write.csv(all_nocoords, "outputs/recordsV.1_extractedvalues_annual.csv")

# occurrence records for monthly data ####
for(i in sprintf('%0.2d', 1:12)){
  # load prism datasets
  prsm_precip = raster(paste("data/PRISM data/ppt/PRISM_ppt_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  # res(prsm_precip)
  prsm_tmean = raster(paste("data/PRISM data/tmean/PRISM_tmean_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  # res(prsm_tmean)
  prsm_tmin = raster(paste("data/PRISM data/tmin/PRISM_tmin_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  # res(prsm_tmin)
  prsm_tmax = raster(paste("data/PRISM data/tmax/PRISM_tmax_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  # res(prsm_tmax)
  prsm_vpdmax = raster(paste("data/PRISM data/vpdmax/PRISM_vpdmax_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  # res(prsm_vpdmax)
  prsm_vpdmin = raster(paste("data/PRISM data/vpdmin/PRISM_vpdmin_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  # res(prsm_vpdmin)
  
  # load CSGIARCSI datasets
  PET = raster(paste('data/CGIARCSI data/et0_month/et0_', i, '.tif', sep = ""))
  # res(PET)
  
  # bind env data to records
  dat = cbind(records, 
              prism_ppt = extract(prsm_precip, st_coordinates(records)), 
              prism_tavg = extract(prsm_tmean, st_coordinates(records)),
              prism_tmin = extract(prsm_tmin, st_coordinates(records)),
              prism_tmax = extract(prsm_tmax, st_coordinates(records)),
              prism_vpdmin = extract(prsm_vpdmin, st_coordinates(records)),
              prism_vpdmax = extract(prsm_vpdmax, st_coordinates(records)),
              CGIARCSI_PET = extract(PET, st_coordinates(records)),
              method = 'simple')
  
  # remove geometry for convenience
  all_nocoords = dat
  all_nocoords$lon = st_coordinates(dat)[,1]
  all_nocoords$lat = st_coordinates(dat)[,2]
  st_geometry(all_nocoords) = NULL
  
  # write to disk
  write.csv(all_nocoords, paste("outputs/recordsV.1_extractedvalues_", i, ".csv", sep = ""))
}

# county records for annual data ####
# load prism datasets
prsm_precip = raster("data/PRISM data/ppt/PRISM_ppt_30yr_normal_4kmM2_annual_asc.asc")
prsm_tmean = raster("data/PRISM data/tmean/PRISM_tmean_30yr_normal_4kmM2_annual_asc.asc")
prsm_tmin = raster("data/PRISM data/tmin/PRISM_tmin_30yr_normal_4kmM2_annual_asc.asc")
prsm_tmax = raster("data/PRISM data/tmax/PRISM_tmax_30yr_normal_4kmM2_annual_asc.asc")
prsm_vpdmax = raster("data/PRISM data/vpdmax/PRISM_vpdmax_30yr_normal_4kmM2_annual_asc.asc")
# res(prsm_vpdmax)
prsm_vpdmin = raster("data/PRISM data/vpdmin/PRISM_vpdmin_30yr_normal_4kmM2_annual_asc.asc")

# reproject CSGIARCSI datasets
aridity = raster('data/CGIARCSI data/ai_et0/at_et0_cropped.tif')
PET = raster('data/CGIARCSI data/et0_yr/et0_yr_cropped.tif')

# resample NPN dataset and write to disk
agdd = raster('data/NPN data/agdd_reprojected.tif')

# load county records
x = "chap"
counties = read_sf(paste("outputs/Q", x, "_bonap.shp", sep = "")) %>% 
  st_transform(crs = 4269)

# mask rasters to extract data
# bind env data to records
prism_ppt = crop(prsm_precip, counties)
prism_ppt = mask(prism_ppt, counties)
prism_tavg = crop(prsm_tmean, counties)
prism_tavg = mask(prism_tavg, counties)
prism_tmin = crop(prsm_tmin, counties)
prism_tmin = mask(prism_tmin, counties)
prism_tmax = crop(prsm_tmax, counties)
prism_tmax = mask(prism_tmax, counties)
prism_vpdmin = crop(prsm_vpdmin, counties)
prism_vpdmin = mask(prism_vpdmin, counties)
prism_vpdmax = crop(prsm_vpdmax, counties)
prism_vpdmax = mask(prism_vpdmax, counties)
CGIARCSI_aridity = crop(aridity, counties)
CGIARCSI_aridity = mask(CGIARCSI_aridity, counties)
CGIARCSI_PET = crop(PET, counties)
CGIARCSI_PET = mask(CGIARCSI_PET, counties)
NPN_agdd = crop(agdd, counties)
NPN_agdd = mask(NPN_agdd, counties)

# county records for monthly data ####


# export mean, min, max, median, stdev, quantiles of 0.01, 0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95, 0.99
# thoughts!