
library(rts)
library(raster)
library(RCurl)

modisProducts()

x=1 # MOD13Q1 es el 1er producto MODIS de la lista
    # generada por modisProducts()

ModisDownload(x=x,h=c(12,12,13),v=c(10,11,11), 
            dates=c('2011.01.01','2011.01.31'),
            MRTpath='c:/MRT/bin', mosaic=T,proj=T,
            proj_type="UTM",utm_zone=29,
            datum="WGS84",pixel_size=250)



