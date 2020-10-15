library(sf)
library(tidyverse)
library(raster)
library(lubridate)
library(rnaturalearth)
library(prism)

# load dataset
records = read_sf("outputs/all_recordsV.1_bonapcleaned.shp")

