# I've now completed the necessary raster processing for the annual data and masked the raster stack for analysis 3. Data will need to be exported.
# processing still needs to be done for monthly datasets and analyses redone.
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
prsm_tmean = raster("data/PRISM data/tmean/PRISM_tmean_30yr_normal_4kmM2_annual_asc.asc")
prsm_tmin = raster("data/PRISM data/tmin/PRISM_tmin_30yr_normal_4kmM2_annual_asc.asc")
prsm_tmax = raster("data/PRISM data/tmax/PRISM_tmax_30yr_normal_4kmM2_annual_asc.asc")
prsm_vpdmax = raster("data/PRISM data/vpdmax/PRISM_vpdmax_30yr_normal_4kmM2_annual_asc.asc")
prsm_vpdmin = raster("data/PRISM data/vpdmin/PRISM_vpdmin_30yr_normal_4kmM2_annual_asc.asc")

# load CSGIARCSI datasets
aridity = raster('data/CGIARCSI data/ai_et0/at_et0_cropped.tif')
PET = raster('data/CGIARCSI data/et0_yr/et0_yr_cropped.tif')

# load NPN datasets
agdd = raster('data/NPN data/agdd_reprojected.tif')

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
write.csv(all_nocoords, "outputs/recordsV.1_extractedvalues_annual.csv", row.names = FALSE)

# occurrence records for monthly data ####
for(i in sprintf('%0.2d', 1:12)){
  # load prism datasets
  prsm_precip_m = raster(paste("data/PRISM data/ppt/PRISM_ppt_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  prsm_tmean_m = raster(paste("data/PRISM data/tmean/PRISM_tmean_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  prsm_tmin_m = raster(paste("data/PRISM data/tmin/PRISM_tmin_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  prsm_tmax_m = raster(paste("data/PRISM data/tmax/PRISM_tmax_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  prsm_vpdmax_m = raster(paste("data/PRISM data/vpdmax/PRISM_vpdmax_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))
  prsm_vpdmin_m = raster(paste("data/PRISM data/vpdmin/PRISM_vpdmin_30yr_normal_4kmM2_", i, "_asc.asc", sep = ""))

  # load CSGIARCSI datasets
  PET_m = raster(paste('data/CGIARCSI data/et0_month/et0_', i, '_projected.tif', sep = ""))

  # bind env data to records
  dat = cbind(records, 
              prism_ppt = extract(prsm_precip_m, st_coordinates(records)), 
              prism_tavg = extract(prsm_tmean_m, st_coordinates(records)),
              prism_tmin = extract(prsm_tmin_m, st_coordinates(records)),
              prism_tmax = extract(prsm_tmax_m, st_coordinates(records)),
              prism_vpdmin = extract(prsm_vpdmin_m, st_coordinates(records)),
              prism_vpdmax = extract(prsm_vpdmax_m, st_coordinates(records)),
              CGIARCSI_PET = extract(PET_m, st_coordinates(records)),
              method = 'simple')
  
  # remove geometry for convenience
  all_nocoords = dat
  all_nocoords$lon = st_coordinates(dat)[,1]
  all_nocoords$lat = st_coordinates(dat)[,2]
  st_geometry(all_nocoords) = NULL
  
  # write to disk
  write.csv(all_nocoords, paste("outputs/recordsV.1_extractedvalues_", i, ".csv", sep = ""), row.names = FALSE)
}

# county records for annual data ####
# load county records
noms = unique(all_nocoords$species)
spp = c("chap", "gem", "hem", "mar", "mic", "phe", "shu", "ste", "vel", "vir")

counties = read_sf(paste("outputs/Q", spp[1], "_bonap.shp", sep = "")) %>% 
  st_transform(crs = 4269)

# stack all rasters of interest
all = raster::stack(prsm_precip,
                    prsm_tmax,
                    prsm_tmean,
                    prsm_tmin,
                    prsm_vpdmax,
                    prsm_vpdmin,
                    aridity,
                    PET,
                    agdd)

# mask rasters to extract data
# bind env data to records
all_mask = mask(all, counties)

df = cbind(
  as.data.frame(all_mask[[1]]),
  as.data.frame(all_mask[[2]]),
  as.data.frame(all_mask[[3]]),
  as.data.frame(all_mask[[4]]),
  as.data.frame(all_mask[[5]]),
  as.data.frame(all_mask[[6]]),
  as.data.frame(all_mask[[7]]),
  as.data.frame(all_mask[[8]]),
  as.data.frame(all_mask[[9]])
)
df$species = noms[1]

for(i in spp[c(2:10)]){
  counties = read_sf(paste("outputs/Q", i, "_bonap.shp", sep = "")) %>% 
    st_transform(crs = 4269)
  
  # stack all rasters of interest
  all = raster::stack(prsm_precip,
                      prsm_tmax,
                      prsm_tmean,
                      prsm_tmin,
                      prsm_vpdmax,
                      prsm_vpdmin,
                      aridity,
                      PET,
                      agdd)
  
  # mask rasters to extract data
  # bind env data to records
  all_mask = mask(all, counties)
  
  df2 = cbind(
    as.data.frame(all_mask[[1]]),
    as.data.frame(all_mask[[2]]),
    as.data.frame(all_mask[[3]]),
    as.data.frame(all_mask[[4]]),
    as.data.frame(all_mask[[5]]),
    as.data.frame(all_mask[[6]]),
    as.data.frame(all_mask[[7]]),
    as.data.frame(all_mask[[8]]),
    as.data.frame(all_mask[[9]])
  )
  df2$species = noms[i]
  df = rbind(df, df2)
}

write.csv(df, "outputs/countiesV.1_extractedvalues_annual.csv", row.names = FALSE)

# county records for monthly data ####
# load county records
for(a in sprintf('%0.2d', 1:12)){
  # load prism datasets
  prsm_precip_m = raster(paste("data/PRISM data/ppt/PRISM_ppt_30yr_normal_4kmM2_", a, "_asc.asc", sep = ""))
  prsm_tmean_m = raster(paste("data/PRISM data/tmean/PRISM_tmean_30yr_normal_4kmM2_", a, "_asc.asc", sep = ""))
  prsm_tmin_m = raster(paste("data/PRISM data/tmin/PRISM_tmin_30yr_normal_4kmM2_", a, "_asc.asc", sep = ""))
  prsm_tmax_m = raster(paste("data/PRISM data/tmax/PRISM_tmax_30yr_normal_4kmM2_", a, "_asc.asc", sep = ""))
  prsm_vpdmax_m = raster(paste("data/PRISM data/vpdmax/PRISM_vpdmax_30yr_normal_4kmM2_", a, "_asc.asc", sep = ""))
  prsm_vpdmin_m = raster(paste("data/PRISM data/vpdmin/PRISM_vpdmin_30yr_normal_4kmM2_", a, "_asc.asc", sep = ""))
  
  # load CSGIARCSI datasets
  PET_m = raster(paste('data/CGIARCSI data/et0_month/et0_', a, '_projected.tif', sep = ""))
  
  # load first species county records
  counties = read_sf(paste("outputs/Q", spp[1], "_bonap.shp", sep = "")) %>% 
    st_transform(crs = 4269)
  
  # stack all rasters of interest
  all = raster::stack(prsm_precip_m,
                      prsm_tmax_m,
                      prsm_tmean_m,
                      prsm_tmin_m,
                      prsm_vpdmax_m,
                      prsm_vpdmin_m,
                      PET_m)
  
  # mask rasters to extract data
  all_mask = mask(all, counties)
  
  # convert to df and cbind
  df = cbind(
    as.data.frame(all_mask[[1]]),
    as.data.frame(all_mask[[2]]),
    as.data.frame(all_mask[[3]]),
    as.data.frame(all_mask[[4]]),
    as.data.frame(all_mask[[5]]),
    as.data.frame(all_mask[[6]]),
    as.data.frame(all_mask[[7]]))
  # create species label
  df$species = noms[1]

  # repeat for all remaining species
  for(i in spp[c(2:10)]){
    counties = read_sf(paste("outputs/Q", i, "_bonap.shp", sep = "")) %>% 
      st_transform(crs = 4269)
    
    # mask rasters to extract data
    # bind env data to records
    all_mask = mask(all, counties)
    
    df2 = cbind(
      as.data.frame(all_mask[[1]]),
      as.data.frame(all_mask[[2]]),
      as.data.frame(all_mask[[3]]),
      as.data.frame(all_mask[[4]]),
      as.data.frame(all_mask[[5]]),
      as.data.frame(all_mask[[6]]),
      as.data.frame(all_mask[[7]]))
    df2$species = noms[i]
    df = rbind(df, df2)
  }
  # write each month to disk
  write.csv(df, paste("outputs/countiesV.1_extractedvalues_", a, ".csv", sep = ""), row.names = FALSE)
}
