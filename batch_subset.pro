; Launch the application
e = ENVI()

; Open a file
File = FILEPATH('qb_boulder_msi', ROOT_DIR=e.ROOT_DIR, $
  SUBDIRECTORY = ['data'])
Raster = e.OpenRaster(file)
 
;coordinates of roi
;MapX, MapY2, MapX2, MapY
 
; Define the geographic subset
Subset = ENVISubsetRaster(Raster, SPATIALREF=SpatialRef, $
  SUB_RECT=[MapX, MapY2, MapX2, MapY])
