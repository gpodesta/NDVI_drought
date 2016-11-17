

# -----------------------------------------------------------------------------#
# --- Erase all objects before starting ----

rm(list = ls()); gc()
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#
# --- Load necessary R packages ----

# --- List of packages to download and load...

list.of.packages <- c("Cairo", "gdalUtils", "Hmisc",
  "lattice", "locfit", "lubridate", "MASS", "ncdf4","RColorBrewer",
  "raster", "rasterVis",
  "reshape2", "rgdal", "rgdalutils","rts", "sp", "spdep",
  "xts", "yaml", "zoo", "dplyr")    

for (pack in list.of.packages) {
  if (!require(pack, character.only = TRUE)) {
    install.packages(pack, dependencies = TRUE)
    require(pack, character.only = TRUE)
  }
}

rm(list.of.packages, pack); gc()
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#
# --- List downloaded HDF files in MODIS13Q1 V6 collection ----

indir <- "D:/sat_data_land/NDVI_Data/HDF/"

if (!dir.exists(indir)) {
  stop('Specified input directory does not exist')
}

ndvi.orig.files <- list.files(path = indir,
  pattern = '.hdf$',
  full.names = TRUE)

# --- Get information about a file SANTI, DEJAME ESTO POR LAS DUDAS

#gdalUtils::gdalinfo(ndvi.orig.files[1])

# --- Get information about the sub-datasets within a file

#gdalUtils::get_subdatasets(datasetname = ndvi.orig.files[1],
#  names_only = TRUE, verbose = TRUE)

rm(indir); gc()
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#
# --- Read outline of Salado Basin A (MIKE active cells)  ----
# --- ESTO A LO MEJOR SE VA A REEMPLAZAR POR ALGUNA MANERA
# --- DE OBTENER EXTENT PARA CROP 
dir.basin <- 'D:/ENSO/Projects/CNH3/data/shapes_cuenca'

tt0 <- file.info(dir.basin)   # Info about directory where basin shapefile is located
if (!tt0$isdir)
  stop("ERROR: Specified directory for basin shapefile does not exist... check name...\n")              

# --- Read shapefile with Basin A boundary

cuenca.A.ll <- rgdal::readOGR(dir.basin,
  layer="Salado_A_latlon",
  verbose = TRUE)
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#
# --- Batch conversion of multiple 'HDF' files into 'geoTiff' files ----

# Define the Proj.4 spatial reference 
# http://spatialreference.org/ref/epsg/26915/proj4/

ll.string <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

# Define output directory for geotiff files
# NOTE: Directory path must NOT have a slash at the end

tif.outdir <- "D:/sat_data_land/NDVI_Data/geotif" # Directory for translated geoTiff files
if (!dir.exists(tif.outdir)) {
  dir.create(tif.outdir)
}

# Convert all HDFs into tiff
# NOTE: argument sd_index = 1 extracts NDVI, if EVI desired sd_index = 2
# TODO: replace hardcoded boundaries ('projwin')

gdalUtils::batch_gdal_translate(
  infiles = ndvi.orig.files,
  of = 'GTiff',
  outdir = tif.outdir,
  sd_index = 1,
  outsuffix = "_ndvi.tif",
  pattern = ".hdf$",
  recursive = FALSE,
  verbose = TRUE)
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#
# --- Build list of GeoTiff files (all tiles, all dates) ----

tif.files <- list.files(path = tif.outdir,
  pattern = '.tif$',
  full.names = TRUE)
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------#





gdalUtils::gdal_translate(src_dataset = ndvi.orig.files[1],
  dst_dataset = 'test.tif',
  sd_index = 1,
  of = "GTiff", strict = TRUE,
  r = "nearest")




input.rasters <- lapply(tif.files, raster::raster)

mos1 <- raster::mosaic(ll1, ll2, tolerance = 0.5, fun = mean)

raster::plot(mos1)

mos1.crp <- raster::crop(mos1, cuenca.A.ll)
mos1.msk <- raster::mask(mos1.crp, cuenca.A.ll)


raster::plot(mos1.crp)
raster::plot(mos1.msk)






full.extent <- raster::union(input.rasters[1], input.rasters[2])

bounding.raster <- raster(full.extent,
  crs=projection(input.rasters[[1]]))






mos1 <- gdalUtils::mosaic_rasters(gdalfile  =c(tif1, tif2),
  dst_dataset = "test_mosaic.tif",
  separate = TRUE,
  of = "GTiff",
  verbose = TRUE)

mos1 <- raster::mosaic(tif1, tif2, tolerance = 0.005, fun = mean)

raster::plot(mos1)





# Project Raster ESTO FUNCIONO!!!

tif1 <- raster::raster(tif.files[1])
tif2 <- raster::raster(tif.files[2])

raster::plot(tif1)
raster::plot(tif2)

ll1 <- raster::projectRaster(tif1, crs = ll.string)
ll2 <- raster::projectRaster(tif2, crs = ll.string)

mos1 <- raster::mosaic(ll1, ll2, tolerance = 0.5, fun = mean)
raster::plot(mos1)

raster::plot(ll1)
raster::plot(ll2)

### ESTO NO FUNCIONO - PROBAS VOS?

mos1 <- gdalUtils::mosaic_rasters(gdalfile = c(ll1, ll2),
  dst_dataset = "test_mosaic.tif",
  separate = TRUE,
  of = "GTiff",
  verbose = TRUE)




# UN PAQUETE TODAVIA NO EN CRAN: MODIS

install.packages("MODIS", repos="http://R-Forge.R-project.org")
library(MODIS)

MODIS:: getCollection(product = 'MOD13Q1',
  collection = NULL,
  newest = TRUE, 
  forceCheck = FALSE,
  as = "character",
  quiet = FALSE)

MODIS::getTile(tileH=12:13,tileV=12)

MODIS::getSds(HdfName = ndvi.orig.files[1], method = 'gdal')




