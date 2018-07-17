# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# joinZonalStats_hyper_BW_pruebas.py
# Created on: 2014-06-07 11:06:16.00000
#   (generated by ArcGIS/ModelBuilder)
# Usage: joinZonalStats_hyper_BW_pruebas <Buffer> <Stats_table> <Grid> <Zone_field_and_join_Field> <Field_Name_Calculate_field> <Expression_Calculate_field> <Expression> <band> <Raster_set> 
# Description:
#This script takes 3 inputs:
#Buffer: zone feature to use as input for zonal statistic tool
#Grid: feature whose table will be used to save the mean values of the zonal statistic tool.
#   This should contain the same features ID field than the "Buffer" input.
#   A field named B1, B2... will be created to store the mean values for each zone for each band. 
#Raster: Raster to use as input for zonal statistic tool, along with the "Buffer".
#	The band information is read from the envi HDR file
###The temporal stats tables are created in the default ArcGIS GDB
# ---------------------------------------------------------------------------

# Import arcpy module
import os
import arcpy, arcgisscripting
import itertools
import re
import traceback, sys

def print_kwinfo():
    if deb==1:
        print "kwinfo se guarda:"
        print kwinfo

def create_if_not_exists(path):
    try:
        if not os.path.exists(path):
            os.makedirs(path)
    except Exception, e:
        # If an error occurred, print line number and error message
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)

def exists(path):
    exists = True if os.path.exists(path)else False
    return exists 

def replace_in_list(regex,lst):
    return [re.sub(regex, '', x).strip() for x in lst] #List comprehension

def print_dict(dictio):
    #The next line iterates, formats and prints the dictionary, key:value
    #print "\n".join('{}={}'.format(k,v) for k,v in dictio.items()) print in console
    arcpy.AddMessage("\n".join('{}={}'.format(k,v) for k,v in dictio.items()))#Print to arcmap results window

##def save_bn_wl():
##    full_bn= '\n'.join(join_str.format(bandn=b, waveln=w) for b,w in itertools.izip(bn, wl)).split('\n')
##
##def save_wl():
##    full_bn= '\n'.join(join_str.format(waveln=w) for w in itertools.izip(wl)).split('\n')
    
##        Starts the script
try:
    # Check out any necessary licenses
    arcpy.CheckOutExtension("spatial")

    # Create the Geoprocessor object
    gp = arcgisscripting.create()
           
    # Load required toolboxes
    print "Start!"
    
    #Type: Feature layer -buffer for the zonalStats
    bf_Lx_1 = arcpy.GetParameterAsText(0)
    L_merge = bf_Lx_1
    arcpy.AddMessage("read b1 " + bf_Lx_1)
    print bf_Lx_1

    #type: Raster layer
    Raster = arcpy.GetParameterAsText(2)
    arcpy.AddMessage("read " + Raster)
    desc = arcpy.Describe(Raster)
    rPath = desc.path
    rdate = desc.baseName[1:7] #Get the date from the raster to create the save feature
    Raster = str(rPath) + "\\" + desc.baseName+ "." +desc.extension
    rname = desc.baseName
    arcpy.AddMessage("Raster source: " + Raster)
    print Raster

    #type: Field - Field for join and statistics
    id_field = arcpy.GetParameterAsText(3)
    arcpy.AddMessage("read " + id_field)

   #type: Feature layer - Feature in whose table the stats will be stored
    folder_storing = arcpy.GetParameterAsText(1)
    Grid = str(folder_storing)+ "\\t" + rdate + bf_Lx_1[0:3]
    #create the feature to extract to
    if not exists(Grid):
        arcpy.CopyFeatures_management(bf_Lx_1, Grid)
    arcpy.AddMessage("read " + Grid)
    desc = arcpy.Describe(Grid)
    gPath = desc.path
    gridSource = str(gPath)
    arcpy.AddMessage("Grid source: " + gridSource)
    gridName = desc.baseName
    arcpy.AddMessage("Grid basename: " + gridName)
    print Grid    

    #List of band names
    hdr_file = os.path.join(str(rPath) + "\\" + rname+".hdr") 


#Folder to store the tables with the stats  
    tempGdb_path = r"C:\Users\usuario\Documents\ArcGIS" 
    tempGdb = r"Default.gdb"
    #This is the path
    tablesPath = os.path.join(tempGdb_path, tempGdb)
    #Keep the individual stats tables?
    #Either way the MEAN is stored to the table of the grid feature selected
    keep_tables=True
# Execute CreateFileGDB
    create_if_not_exists(tempGdb_path)
    if not exists(tablesPath):
        arcpy.CreateFileGDB_management(tempGdb_path, tempGdb)
    print tablesPath
    
# Local variables:
    arcpy.AddMessage("Local variables")
    print "Local variables"
    Zone_field_and_join_Field = id_field
    gridLayer = "gridLayer"


## Make a layer
    print "Make layer"
    arcpy.MakeFeatureLayer_management(Grid, "gridLayer")

    ############################################################################
    i=1
    bandField = "B1"
    band = Raster
    print bandField
    #Set table name
    tableName = gridName + "_" + bandField #+ ".dbf"
    L_Stats_table = tablesPath + "\\" + tableName
    print L_Stats_table
    Field_Name_Calculate_field = gridName + "." + bandField
    print Field_Name_Calculate_field
    Expression_Select_layer = tableName+".Mean IS NOT NULL"
    # Use this if the stats were saved to a dbf file "\""+tableName+".Mean\" IS NOT NULL"
    # Use this if the stats were saved to a table "\""+tableName+":Mean\" IS NOT NULL"
    # Use this if the stats were saved to a database table tableName+".Mean IS NOT NULL"
    print Expression_Select_layer
    Expression_Calculate_field = "round(!"+tableName+".Mean!,2)"
    #the "!"+tableName+":Mean!" notation (:)is used when the stats are saved to a table
    #the "!"+tableName+".Mean!" notation (.)is used when the stats are saved to a dbf file
    print Expression_Calculate_field
    
    # Process: Zonal Statistics as Table
    print "Zonal statistics..."
    #Perform the zonalstatistics getting only the "MEAN" value of the cells
    #"MEAN" can be changed to get different statistics:
    #ALL,MEAN,MAJORITY,MAXIMUM,MEDIAN,MINIMUM,MINORITY,RANGE,STD,SUM,VARIETY,MIN_MAX,MEAN_STD,MIN_MAX_MEAN 
    #arcpy.AddMessage("zs exists? : " + str(exists(path)))
    zs = arcpy.gp.ZonalStatisticsAsTable_sa(L_merge, Zone_field_and_join_Field, band, L_Stats_table, "DATA", "MEAN")
    arcpy.AddMessage("stats table: " + str(zs))
    fields = gp.ListFields(gridLayer, bandField)
    field_found = fields.Next()
    if (not field_found):
        arcpy.AddField_management(gridLayer, bandField, "FLOAT", 10, 3, "", "", "NULLABLE", "NON_REQUIRED", "")
        arcpy.AddMessage("Added. Before field not found " + str(bandField))
    else:
        arcpy.AddMessage("field_found " + str(field_found.name))
        arcpy.AddMessage("field found " + str(bandField))
    
    # Process: Add Join
    print "Joining..."
    arcpy.AddMessage("grid..."+ gridLayer)
    arcpy.AddMessage("field..."+Zone_field_and_join_Field)
    arcpy.AddJoin_management(gridLayer, Zone_field_and_join_Field, zs, Zone_field_and_join_Field, "KEEP_ALL")    

    # Process: Select Layer By Attribute
    if i==1:
        print "Selecting Layer..."
        gridLayerSelection = arcpy.SelectLayerByAttribute_management(gridLayer, "NEW_SELECTION", Expression_Select_layer)

    # Process: Calculate Field
    print "Calculating field"
    arcpy.AddMessage("Calculating field...")   
    arcpy.CalculateField_management(gridLayerSelection, Field_Name_Calculate_field, Expression_Calculate_field, "PYTHON")

    # Process: Remove Join
    arcpy.AddMessage("remove Join")
    arcpy.RemoveJoin_management(gridLayer, "")
    #Erase stats table
    if not keep_tables: arcpy.Delete_management(zs)        
###############################################################################          
    print "Finish"

except Exception, e:
    # If an error occurred, print line number and error message
    import traceback, sys
    tb = sys.exc_info()[2]
    arcpy.AddMessage("Line:" + str(tb.tb_lineno))
    arcpy.AddMessage("Error " + e.message)
    print "OMG!"
  

