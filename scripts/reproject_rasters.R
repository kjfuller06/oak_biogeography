library(raster)

# load county data
counties = read_sf("data/county boundaries/acs_2012_2016_county_us_B27001.shp") %>% 
  st_transform(crs = 4269)

# reproject CSGIARCSI datasets
aridity = raster('data/CGIARCSI data/ai_et0/ai_et0.tif')
aridity = crop(aridity, extent(-130, -50, 19, 54))
aridity = projectRaster(aridity, crs = "+proj=longlat +datum=NAD83 +no_defs")
writeRaster(aridity, 'data/CGIARCSI data/ai_et0/at_et0_reprojected.tif', overwrite = TRUE)
aridity = crop(aridity, counties)
aridity = aggregate(aridity, fact = 5)
writeRaster(aridity, 'data/CGIARCSI data/ai_et0/at_et0_cropped.tif', overwrite = TRUE)
PET = raster('data/CGIARCSI data/et0_yr/et0_yr.tif')
PET = crop(PET, extent(-130, -50, 19, 54))
PET = projectRaster(PET, crs = "+proj=longlat +datum=NAD83 +no_defs")
writeRaster(PET, 'data/CGIARCSI data/et0_yr/et0_yr_reprojected.tif', overwrite = TRUE)
PET = crop(PET, counties)
PET = aggregate(PET, fact = 5)
writeRaster(PET, 'data/CGIARCSI data/et0_yr/et0_yr_cropped.tif', overwrite = TRUE)

# resample NPN dataset and write to disk
agdd = raster('data/NPN data/data.tif')
agdd = crop(agdd, extent(-130, -50, 19, 54))
agdd = resample(agdd, prsm_precip, method = 'ngb')
agdd = crop(agdd, counties)
writeRaster(agdd, 'data/NPN data/agdd_reprojected.tif', overwrite = TRUE)
