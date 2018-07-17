PRO test; Start the application
  e = ENVI()
  
  ; Open an input file
  file = FILEPATH('150110_bw2_spr.bsq', ROOT_DIR='E:\150110\h150110\', $
      SUBDIRECTORY = ['ortho_res'])
  raster = e.OpenRaster(file)
  
  ; generate a mask
  mask = (raster.GetData(BAND=0) ge 220)
  
  ; write out the mask to a file
  file = FILEPATH('test3.bsq', ROOT_DIR='c:\vuelos\', $
    SUBDIRECTORY = ['temp'])
  maskRaster = ENVIRaster(mask, URI=file)
  maskRaster.Save
  
  ; create a masked raster
  rasterWithMask = ENVIMaskRaster(raster, MaskRaster)
  
  ; display the new raster, the masked areas are transparent
  view = e.GetView()
  layer = view.CreateLayer(rasterWithMask)
END