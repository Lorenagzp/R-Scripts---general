import arcpy
from os.path import exists, join
from os import makedirs
#Folder which will be checked if exists
dates= ['160505','160509','160514','160520','160525']
img= 'm'
d= ['msk','ndvi']
drive_path= 'G:\\AD15_16'

def checkCreateFolder(f):
    print("path to check: " + str(f))
    #Method to Create folder if it doesn't exist
    try:
        if arcpy.os.path.exists(f):
            print('exists')
        else:
            arcpy.os.makedirs(f)
            print('created')
    except: 
        print('error')

#Iterate method to several dates
for date in dates:
    for i in d:
        folder = arcpy.os.path.join(drive_path,date,img,i)
        checkCreateFolder(folder)