##Arcpy on Python Console ArcMAP
#################### CHANGE SYMBOLOGY###############
import arcpy, sys

try:
    symbologyLayer = arcpy.mapping.Layer(sys.argv[1])
except:
    arcpy.AddError("Input parameters could not be resolved")
    sys.exit(-1)

arcpy.AddMessage("Source Layer is %s" % symbologyLayer.symbologyType)

# Exit if the source layer is broken
if symbologyLayer.isBroken:
    arcpy.AddError("Source layer is broken")
    sys.exit(-2)

# Exit if the source layer is not a raster layer
if not symbologyLayer.isRasterLayer:
    arcpy.AddError("Source layer is not a raster layer")
    sys.exit(-3)    
mxd = arcpy.mapping.MapDocument("Current") # This MXD

#df = arcpy.mapping.ListDataFrames(mxd,"Georgia")[0] # the first data frame called Georgia
df = arcpy.mapping.ListDataFrames(mxd)[0] # Just the first data frame in the MXD
rasters = arcpy.mapping.ListLayers(mxd,"*",df) # all the layers

for ThisLayer in rasters:
    arcpy.AddMessage( "Working on " + ThisLayer.name)
    if not ThisLayer.isBroken: # only try to work with layers that aren't broken
        arcpy.AddMessage( "-not broken")
        if not ThisLayer.name.upper() == symbologyLayer.name.upper():
            arcpy.AddMessage( "-not the source layer")
            # not the source layer
            if ThisLayer.isRasterLayer:
                arcpy.AddMessage( "-is a raster layer")
                # only applies to raster layers
                arcpy.CalculateStatistics_management(ThisLayer.dataSource)
                arcpy.AddMessage( "--Statistics calculated")
                arcpy.AddMessage( "--Raster symbology is %s" % ThisLayer.symbologyType)
                arcpy.ApplySymbologyFromLayer_management(ThisLayer,symbologyLayer)
                arcpy.AddMessage( "--Symbology Applied")

#mxd.save() # I'm not saving, uncomment this to save
del mxd


############################ TURN ON AND OFF##########################

l1 = arcpy.mapping.Layer(r'h160303\h160303bgsort.bsq') # Get layer by its name (belongs to group)
#l1.longName # This will give the name including the group

#A list of layer names that you want to be turned off.
names = [x,y,z,etc]

mxd = arcpy.mapping.MapDocument("current")
df = arcpy.mapping.ListDataFrames(, mxd, "Layers")[0] #Get the 1st dataframe called "Layers"
layers = arcpy.mapping.ListLayers(mxd, "*", df)

for layer in layers:
  if layer.name in names:
    layer.visible = False

arcpy.RefreshTOC()
arcpy.RefreshActiveView()

###################turn off layer in group layer h160303?
#lyr.isGroupLayer == 1      
mxd = arcpy.mapping.MapDocument("current")
df = arcpy.mapping.ListDataFrames(mxd, "Layers")[0] #Get the 1st dataframe called "Layers"
groupLayer = arcpy.mapping.Layer(r'h160303') # fixed the name of the group layer
for i in arcpy.mapping.ListLayers(groupLayer): print (i) ## Print layers in group layer, INCLUDES THE layer group itself
for i in arcpy.mapping.ListLayers(groupLayer): i.visible = True ## Turn Off layers in group layer
>>> arcpy.RefreshTOC() # Refresh Layers Panel

## Calsulate statistics and apply symbology from layer on all layer of group layer

layerRef = arcpy.mapping.Layer("h160303bgsort.bsq") #Layer to use as symbology, hardcoded
groupLayer = arcpy.mapping.Layer(r'h160303') # fixed the name of the group layer
for i in arcpy.mapping.ListLayers(groupLayer):
    if not i.isGroupLayer:
        if not i.name.upper() == layerRef.name.upper(): #If its not the reference layer
            if i.isRasterLayer: #apply only to rasters
                arcpy.CalculateStatistics_management(i.dataSource,"1","1","0")
                arcpy.ApplySymbologyFromLayer_management(i,layerRef)
                i.visible = False    #Uncheck visibility
arcpy.RefreshTOC() #Apply the layer state update: visibility
arcpy.RefreshActiveView()

