import arcpy

mxd = arcpy.mapping.MapDocument("CURRENT")
df = arcpy.mapping.ListDataFrames(mxd)[0]
rasters = arcpy.mapping.ListLayers(mxd, "", df)
templatelyr = r"D:\AB2013-2014\Bread_wheat\Imag\140328H_810_1_layer_template_min_max.lyr"
arcpy.AddMessage(templatelyr)
for layer in rasters:
	t_lyr = arcpy.mapping.Layer(templatelyr)
	arcpy.AddMessage(layer[:-3])
	if layer.isRasterLayer and layer.name[:-3]=="bsq":
		arcpy.AddMessage("working on: "+layer.name)
		arcpy.CalculateStatistics_management(layer)
		arcpy.ApplySymbologyFromLayer_management(layer, t_lyr)

#completely fixed way		
import arcpy

mxd = arcpy.mapping.MapDocument("CURRENT")
df = arcpy.mapping.ListDataFrames(mxd)[0]
rasters = arcpy.mapping.ListLayers(mxd, "", df)
templatelyr = r"D:\AB2013-2014\Bread_wheat\Imag\140328H_810_1_layer_template_min_max.lyr"
layer = "140328H_810_2.bsq"
arcpy.CalculateStatistics_management(layer)
arcpy.ApplySymbologyFromLayer_management(layer, t_lyr)
del mxd