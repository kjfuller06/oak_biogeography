library(raster)

# reproject CSGIARCSI datasets
aridity = raster('data/CGIARCSI data/ai_et0/ai_et0.tif')
aridity = aggregate(aridity, fact = 5)
aridity = projectRaster(aridity, crs = "+proj=longlat +datum=NAD83 +no_defs")
PET = raster('data/CGIARCSI data/et0_yr/et0_yr.tif')
PET = aggregate(PET, fact = 5)
PET = projectRaster(PET, crs = "+proj=longlat +datum=NAD83 +no_defs")
# write new layers to disk
writeRaster(aridity, 'data/CGIARCSI data/ai_et0/at_et0_reprojected.tif')
writeRaster(PET, 'data/CGIARCSI data/et0_yr/et0_yr_reprojected.tif')

# resample NPN dataset and write to disk
agdd = raster('data/NPN data/data.tif')
agdd = resample(agdd, prsm_precip, method = 'ngb')
writeRaster(agdd, 'data/NPN data/agdd_resprojected.tif')