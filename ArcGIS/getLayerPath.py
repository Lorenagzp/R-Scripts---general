from os.path import exists

#Get layer to obtain absolute path
layer = arcpy.GetParameterAsText(0)
arcpy.AddMessage("Layer is: " + layer)
desc = arcpy.Describe(layer)
path = desc.path
arcpy.SetParameterAsText(1, str(path))
