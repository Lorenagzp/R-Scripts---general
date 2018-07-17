  
::  Autor: Gil Thompson	
::  Fecha: 09/11/17      
::  Descr: TEST Generador de proyectos en Pix4D desde bash win 
:: Falta test Ag Multispectral 3d-maps

:: Direccion de la carpeta de imgs
set path= "E:\MEDICIONES PHY MATRICE_2017\PHY_SQ_DRIP_REDEDGE_170323\0001SET\000"

@echo %time%
"C:\Program Files\Pix4dmapper\Pix4dmapper" -c -n --image-dir  %path%  --template ag-multispectral  "E:\MEDICIONES PHY MATRICE_2017\PHY_SQ_DRIP_REDEDGE_170323\PHY_SQ_DRIP_REDEDGE_170323.p4d"
@echo %time%


pause

"C:\Program Files\Pix4dmapper\Pix4dmapper" -c -i  "E:\MEDICIONES PHY MATRICE_2017\PHY_SQ_DRIP_REDEDGE_170323\PHY_SQ_DRIP_REDEDGE_170323.p4d"

exit b