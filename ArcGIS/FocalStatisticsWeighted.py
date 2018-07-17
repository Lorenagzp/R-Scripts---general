import arcpy
from arcpy import env
from arcpy.sa import *

env.workspace = "C:"

# Local variables:
inRaster = arcpy.GetParameterAsText(0)
inkarnelfile = arcpy.GetParameterAsText(1)
neighborhood = NbrWeight(inkarnelfile)

# Check out any necessary licenses
arcpy.CheckOutExtension("spatial")

# Execute FocalStatistics
outFocalStatistics = FocalStatistics(inRaster, neighborhood, "MEAN")

# Save the output
saveLocation = arcpy.GetParameterAsText(2)
outFocalStatistics.save(saveLocation)