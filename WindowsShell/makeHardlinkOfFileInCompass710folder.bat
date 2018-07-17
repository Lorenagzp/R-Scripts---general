@echo off
cls
REM The selected inputs names will be used to generate the hardlink on the compass 710 AF Folder
REM 
for %%f in (%*) do (
mklink /H C:\Dropbox\AFebee\compass\710\%%~nxf %%f
echo C:\Dropbox\AFebee\compass\710\%%~nxf
echo %%f
)
echo Finished
pause