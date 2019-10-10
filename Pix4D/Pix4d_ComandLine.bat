::  Autor: Gil Thompson	
::  Fecha: 09/11/17      
::  Descr: TEST Generador de proyectos en Pix4D desde bash win 
:: Falta test Ag Multispectral 3d-maps
:: Direccion de la carpeta de imgs

:: -c > modo linea de comandos 
:: -n > nuevo proyecto 
:: -i > Correr paso 1, -d>2,  -o>3
:: --template-list >		 Template-name :                              Description
::---------------------------------------- : ----------------------------------------
::                                 3d-maps :                                  3D Maps
::                           3d-maps-rapid :                  3D Maps - Rapid/Low Res
::                               3d-models :                                3D Models
::                         3d-models-rapid :                3D Models - Rapid/Low Res
::                      ag-modified-camera :                       Ag Modified Camera
::                ag-modified-camera-rapid :       Ag Modified Camera - Rapid/Low Res
::                        ag-multispectral :                         Ag Multispectral
::                                  ag-rgb :                                   Ag RGB
::                            ag-rgb-rapid :                   Ag RGB - Rapid/Low Res
::                          thermal-camera :                           Thermal Camera
::                        thermomap-camera :                         ThermoMAP Camera
::---------------------------------------- : ----------------------------------------


echo RUNNING PROJECT <project_name>
:: Ejecucion para batch mode segun pix4D
::"<pix4dmapper_path/pix4dmapper.bat>" -c -r "<project_file_path>"



set path= "C:\Program Files\Pix4Dmapper\tutorial\images"

@echo %time%
::"C:\Program Files\Pix4dmapper\Pix4dmapper" -c -n --image-dir  %path%  --template ag-multispectral  
::"C:\Users\ITHOMPSON\Documents\temp\1_80\phy_Heat_A_Am_RedEdge_180529_incompleto.p4d"

"C:\Program Files\Pix4dmapper\Pix4dmapper" -c -n --image-dir  %path%  --template 3d-maps  
"C:\Program Files\Pix4Dmapper\tutorial\images\example.p4d"


@echo %time%



pause

: "C:\Program Files\Pix4dmapper\Pix4dmapper" -c -i  
: "C:\Users\ITHOMPSON\Documents\temp\1_80\phy_Heat_A_Am_RedEdge_180529_incompleto.p4d"

 "C:\Program Files\Pix4dmapper\Pix4dmapper" -c -i  
 "C:\Program Files\Pix4Dmapper\tutorial\images\example.p4d"

echo PROCESSING FINISHED
pause

exit b
