# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# extract_data_multi6bandas.py
# Created on: 2015-07-10 11:06:16.00000
# Description:
#This script takes 3 inputs:
#Buffer: zone feature to use as input for zonal statistic tool
#Grid: feature whose table will be used to save the mean values of the zonal statistic tool.
#   This should contain the same features ID field than the "Buffer" input.
#   A field named B1, B2... will be created to store the mean values for each zone for each band. 
#Raster: Raster to use as input for zonal statistic tool (stats table stored in the feature location), along with the "Buffer".
#	The script will iterate 6 bands
###The temporal stats tables are created in the default ArcGIS GDB
# ---------------------------------------------------------------------------

# Import arcpy module
import os
import arcpy, arcgisscripting
import itertools
import traceback, sys

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
    
##   starts the script
try:
    # Check out any necessary licenses
    arcpy.CheckOutExtension("spatial")

    # Create the Geoprocessor object
    gp = arcgisscripting.create()
           
    # Load required toolboxes
    print "Start!"
    #Type: Feature layer of plots areas to extract data from the raster
    bf_Lx_1 = arcpy.GetParameterAsText(0)
    L_merge = bf_Lx_1
    arcpy.AddMessage("read buffer1 " + bf_Lx_1)
    print bf_Lx_1

    #type: Feature layer - Feature in whose table the stats will be stored. 
	#Needs to have a field matching the ID field, because a Join is made ith it
    Grid = arcpy.GetParameterAsText(1)
    arcpy.AddMessage("read " + Grid)
    desc = arcpy.Describe(Grid)
    gPath = desc.path
    gridSource = str(gPath) + "\\" + Grid
    arcpy.AddMessage("Grid source: " + gridSource)
    gridName = desc.baseName
    arcpy.AddMessage("Grid basename: " + gridName)
    
    print Grid
    #type: Raster layer from which data will be extracted
    Raster = arcpy.GetParameterAsText(2)
    arcpy.AddMessage("read " + Raster)
    desc = arcpy.Describe(Raster)
    rPath = desc.path
    Raster = str(rPath) + "\\" + desc.baseName+ "." +desc.extension
    arcpy.AddMessage("Raster source: " + Raster)
    print Raster

    #type: Field - Field for join and statistics
    id_field = arcpy.GetParameterAsText(3)
    arcpy.AddMessage("read " + id_field)

    #Number of bands
    bandNumber = desc.bandCount
    arcpy.AddMessage("Number of bands: "+str(bandNumber))

    #Folder to store the tables with the stats  
    tempGdb_path = r"C:\Users\usuario\Documents\ArcGIS" 
    tempGdb = r"Default.gdb"
    #This is the path
    tablesPath = os.path.join(tempGdb_path, tempGdb)
    
    #Keep the individual stats tables?
    #Either way the MEAN is stored to the table of the grid feature selected
    keep_tables=False
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

	#It is assumed that the Band names are something like "Band_1"
    for b in range(1, bandNumber+1):
        arcpy.AddMessage("band: " + str(b))
        band = Raster + "\\Band_" + str(b)
        arcpy.AddMessage("band: " + band)
        bandField = "B" + str(b)
        print bandField
        #Set table name
        tableName = gridName + "_" + bandField #+ ".dbf"
        L_Stats_table = tablesPath + "\\" + tableName
        print L_Stats_table
        Field_Name_Calculate_field = gridName + "." + bandField
        print Field_Name_Calculate_field
		
        #Expression_Select_layer = tableName+".Mean IS NOT NULL"
        # Use this if the stats were saved to a dbf file "\""+tableName+".Mean\" IS NOT NULL"
        # Use this if the stats were saved to a table "\""+tableName+":Mean\" IS NOT NULL"
        # Use this if the stats were saved to a database table tableName+".Mean IS NOT NULL"
        #print Expression_Select_layer
		
		#Round values
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
		
        ##Chech if the field where the value will be store exists
		##Otherwise, create it
        fields = gp.ListFields(gridLayer, bandField)
        field_found = fields.Next()
        if (not field_found):
            arcpy.AddField_management(gridLayer, bandField, "FLOAT", 10, 3, "", "", "NULLABLE", "NON_REQUIRED", "")
            arcpy.AddMessage("Field not found, added: " + str(bandField))
        else:
            arcpy.AddMessage("field_found " + str(field_found.name))
            arcpy.AddMessage("field found " + str(bandField))
        
        # Process: Add Join
        print "Joining..."
        arcpy.AddMessage("grid..."+ gridLayer)
        arcpy.AddMessage("field..."+Zone_field_and_join_Field)
        arcpy.AddJoin_management(gridLayer, Zone_field_and_join_Field, zs, Zone_field_and_join_Field, "KEEP_ALL")    

        # Process: Calculate Field
        print "Calculating field"
        arcpy.AddMessage("Calculating field...")   
        arcpy.CalculateField_management(gridLayer, Field_Name_Calculate_field, Expression_Calculate_field, "PYTHON")

        # Process: Remove Join
        arcpy.AddMessage("remove Join")
        arcpy.RemoveJoin_management(gridLayer, "")
        #Erase stats table
        if not keep_tables: arcpy.Delete_management(zs)        
              
    print "Finish"

except Exception, e:
    # If an error occurred, print line number and error message
    import traceback, sys
    tb = sys.exc_info()[2]
    arcpy.AddMessage("Line:" + str(tb.tb_lineno))
    arcpy.AddMessage("Error " + e.message)
    print "OMG!"
  

