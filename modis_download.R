


# MODISTools – downloading and processing MODIS remotely sensed data in R
# Sean L Tuck, Helen RP Phillips, Rogier E Hintzen,
# Jörn PW Scharlemann, Andy Purvis,and Lawrence N Hudson.
# Ecol Evol. 2014 Dec; 4(24): 4658–4668.
# doi:  10.1002/ece3.1273 - PMCID: PMC4278818

library(rts)
library(raster)
library(RCurl)

rts::modisProducts()

# --- Definir el producto MODIS que se quiere bajar.

x <- 1 # MOD13Q1 es el 1er producto MODIS de la lista
    # generada por modisProducts()

# Number  Product Platform  Name                Type  Resolution  Temporal
# 1       MOD13Q1 Terra     Vegetation Indices  Tile  250m        16 day
# 52      MYD13Q1 Aqua      Vegetation Indices  Tile  250m        16 day

#Citation for data set:
#K. Didan. (2015). MOD13Q1 MODIS/Terra Vegetation Indices
#16-Day L3 Global 250m SIN Grid V006.
#NASA EOSDIS Land Processes DAAC.
#http://doi.org/10.5067/MODIS/MOD13Q1.006

# Acknowledgement for LP DAAC tools and/or services:
# The MODIS vegetation indices products were retrieved from the
# NASA EOSDIS Land Processes Distributed Active Archive Center (LP DAAC),
# USGS/Earth Resources Observation and Science (EROS) Center,
# Sioux Falls, South Dakota.


rts::ModisDownload(x = 'MOD13Q1',
  h = c(12), v = c(12), 
  dates = c('2016.08.01','2016.08.31'),
  MRTpath='C:/MRT/bin',
  mosaic = TRUE,
  proj = TRUE,
  proj_type = "UTM", utm_zone = '20H',
  datum = "WGS84", pixel_size = 250)


ttt <- raster::raster(x = 'D:/test.250m_16_days_NDVI.tif')

# http://rpackages.ianhowson.com/rforge/rts/man/ModisDownload.html

rts::ModisDownload(x = 1,
  h = c(12), v = c(12),
  dates = '2015.08.13',
  mosaic = FALSE, proj = FALSE)


raster::modisHDF(x = 1,
  h = c(12), v = c(12),
  dates = '2015.08.13')

