  ;+
  ; :Author: Lorena 4/09/2015
  ;-
  ;+
  ; :Description:
  ;
  ; Mask and subset hyper raster
pro ENVIMaskRasters
  compile_opt idl2
  ; Start the application
  e = ENVI()
  ;-------------Inputs and mask----------------
  ;test location
  test5 = FILEPATH('test5.bsq', ROOT_DIR='c:\vuelos\', $
    SUBDIRECTORY = ['temp'])

  test4 = FILEPATH('test14.bsq', ROOT_DIR='c:\vuelos\', $
    SUBDIRECTORY = ['temp'])
    
  test6 = FILEPATH('test10.bsq', ROOT_DIR='c:\vuelos\', $
    SUBDIRECTORY = ['temp'])
  
  ; Open an input file
  PRINT, 'Open the input file.'
  filei = FILEPATH('150110_bw2_spr.bsq', ROOT_DIR='E:\150110\h150110\', $
    SUBDIRECTORY = ['ortho_res'])
  raster = e.OpenRaster(filei)
  
  ; Open the mask file
  PRINT, 'Open the mask file.'
  filem = FILEPATH('150110_bw2msk.tif', ROOT_DIR='E:\150110\h150110\', $
    SUBDIRECTORY = ['mask'])
  maskFile = e.OpenRaster(filem)
  ;maskRas = (maskFile EQ 1 )
  
  
;  ; create a masked raster
;  PRINT, 'Mask raster'
;  rasterWithMask = ENVIMaskRaster(raster, maskFile)
;;
;;  PRINT, 'Save masked raster.'
;;  rasterWithMask.Export, test5, 'envi'
;
;;-------------Spatial subset----------------
;; This is the area of interest:
;UpperLeftLat = 27.386274
;UpperLeftLon = -109.922458
;LowerRightLat = 27.381419
;LowerRightLon = -109.915562
;
;; Get the spatial reference of the raster
;SpatialRef = raster.SPATIALREF
;
;; Convert from Lon/Lat to MapX/MayY
;SpatialRef.ConvertLonLatToMap, UpperLeftLon, UpperLeftLat, MapX, MapY
;SpatialRef.ConvertLonLatToMap, LowerRightLon, LowerRightLat, MapX2, MapY2
;
;; Define the geographic subset
;subset = ENVISubsetRaster(rasterWithMask, SPATIALREF= SpatialRef, $
;  SUB_RECT=[MapX, MapY2, MapX2, MapY])
;
;;Save the masked subset of the raster
;;mkdfile = FILEPATH('h150110bw2mkd.bsq', ROOT_DIR='E:\150110\h150110\', $
;  ;SUBDIRECTORY = ['mask'])
;  subset.Export, test6, 'envi'    
  ;------------DISLAY-----------------
  ; display the new raster, the masked areas are transparent
  viewss = e.GetView()
  viewss.Zoom, /FULL_EXTENT
  layer1 = viewss.CreateLayer(maskFile)
  ;
end