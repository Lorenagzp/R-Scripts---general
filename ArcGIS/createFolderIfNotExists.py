from os.path import exists
from os import makedirs

#Folder which will be checked if exists
folder = arcpy.GetParameter(0)
folder = str(folder)
arcpy.AddMessage("path to check: " + str(folder))
folder.replace("\\", "\\\\")

#Create folder if it doesn't exist
try:
    os.makedirs(folder)
    os.path.exists(folder)
except: 
    os.makedirs(folder)
ready = folder
arcpy.SetParameterAsText(1,ready)