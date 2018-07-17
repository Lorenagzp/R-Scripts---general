pro kelvin2celsius
  compile_opt idl2

  e = ENVI(); Start ENVI. ENVI help code

  CATCH, theError; Establish error handler.
  IF theError NE 0 THEN BEGIN;This statement begins the error handler:
    Catch, /Cancel
    Help, /Last_Message, Output=theErrorMessage
    FOR j=0,N_Elements(theErrorMessage)-1 DO BEGIN
      Print, theErrorMessage[j]
    ENDFOR
    RETURN
  ENDIF
  
  ;Pick file dialog:
  fileKelvin = DIALOG_PICKFILE(PATH='E:', $
    TITLE='Select image in kelvin units to convert to celsius',  FILTER='*.tif')
  print,'File: ' + fileKelvin
  rasterKelvin = e.OpenRaster(fileKelvin)
  ; Convert from kelvin x 100 to celsius
  thermal = ((rasterKelvin.GetData(BANDS=0))/100)-273.15
  
  ; Determine an output file
  outFile = file_dirname(fileKelvin, /MARK_DIRECTORY)+file_basename(fileKelvin, '.tif') + '_c.bsq'
  fileThermal = ENVIRaster(thermal, URI=outFile, NBANDS=1)
  ;Save file in celsius degrees 
  ;The header needs to be created
  ;We want to use a ROI to crop the image
  fileThermal.Save
  ;Save to TIF
  ;The header needs to be created
  outFileTif = file_dirname(fileKelvin, /MARK_DIRECTORY)+file_basename(fileKelvin, '.tif') + '_c.tif'
  WRITE_TIFF, outFileTif,fileThermal,/float
end