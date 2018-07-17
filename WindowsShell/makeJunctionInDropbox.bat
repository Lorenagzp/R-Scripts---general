@echo off
cls
set /p var=Name of the Junction folder to be created in Dropbox/NAS/AF Folder
mklink /J c:\Dropbox\NAS\AF\%var% %1
echo Finished
pause