#Perform zonal statistics tool based on a a shapefile and a folder with many rasters of the same area
#The inputs are specified as para meters in the tool in ArcMap


#This script is to execute the "Zonal statistics" tool in a multiband raster. It saves the resulting table to a specified >workspace<.
# One table per band is generated, they are named based on the raster and feature zone names + the extracted band number.
# To iterate along the bands, the ENVI HDR file is atempted to be read to get the band names.
# If header doesn't exist, a known number of bands can be specified to iterate.
#This script takes 3 important inputs and outputs:
#(input)
# Buffer: zone feature to use as input for zonal statistic tool.
#   Standard file name system on the features is espected: tttYYMMDDfff
#   Being:
#   YYMMDD= date in a YYMMDD format. E.g. 160311 for march 11 of 2016.
#   fff = 3 char indicating the features that are represented in the vector shapes. E.g. "gss" for greenseeker sampling, "plt" for field plots.
#   ttt = 3 char representing the trial or area covered in the image. E.g. "bwh" for bread wheat trials, "sam" for maize summer trials

# ID field: Field of the input feature to use as identifier of the different zones for generating the statistics

# image folder:  data image to use as input for zonal statistic tool.
#   Standard file name system on the raster is espected: xYYMMDDtttsss
#   Being:
#   x = [h,m,t,c,a,r,n] one char representing the camera used to acquire the imagery
    #   sss = 3 char representing the processing stage of the imagery. E.g. "geo" for georeferenced, "pno" for the multi mosaic  
#   The band information is read from the envi HDR file

# Workspace: where to save the statistics tables and where to create the features to save the mean values per plot

# Known bands: [Optional] Number of bands of the input raster. Necessary if
#   the header file doesn't exist -> default is 1 if not specified.

from functions_extraction import * 
from os import listdir #Para listar los rasters in la carpeta
        
try:      
    # Check out any necessary licenses and Create the Geoprocessor object
    arcpy.CheckOutExtension("spatial")
    gp = arcgisscripting.create()
    #########################################################################################
    ################################# START:INPUTS ##########################################

    #plotsF is the zonal polygons to use in the zonal statistics
    plotsF = arcpy.GetParameterAsText(0) #BW
    id_field = arcpy.GetParameterAsText(1) #Table field that has the unique plot identifier

    #imgWs="G:\\AD15_16\\" #imageBaseLocation    
    imgWs = arcpy.GetParameterAsText(2) #test
    arcpy.env.workspace = imgWs
    arcpy.AddMessage("wspace: "+str(arcpy.env.workspace))
    ext=arcpy.GetParameterAsText(3) #extension of the rasters
    #knownBands when there is no header to read
    knownBands=arcpy.GetParameterAsText(4) # ####################### thermal =1, hyper resampled = 62, sequoia =4

    #tws = where to save tables inside the workspace
    tws =arcpy.GetParameterAsText(5)######Not worinkg... it saves a folder up#######


    # Text file to save the history of procesing
    log= arcpy.GetParameterAsText(6)

    ## END:INPUTS ##
    #########################################################################################
    files = listdir(imgWs)
    #find the image and features to perform the zonal statistics
    arcpy.AddMessage("Zones: "+ plotsF)
    for r, img in enumerate(files):
        #If the raster is valid
        if img.endswith('.' + ext):
            arcpy.AddMessage(str(img)+" -- Will be processed")
            #PREPARE FOR THE ZS
            #Reading header to get Bands
            #We assume header file is there and named as the raster
            hdr_file = img[:-4]+".hdr"
            #Read header to know number and name of bands or set them a priori
            #knownBands is optional
            bandNames = readHeaderFile(hdr_file, knownBands)
            tableBaseName = tws+"//"+img[:-4] #stats table base name in ws. Use the name of the raster without extention
            #arcpy.AddMessage("zs")
            #arcpy.AddMessage("tb:"+tableBaseName)
            zsm = zonalStatsMultiband(tableBaseName, bandNames, img, plotsF,id_field)
            appendListToFile(log,zsm,mode="a")
        else:
            #arcpy.AddMessage("|||No raster to use |||")
            appendListToFile(log,"No raster to use"+str(img),mode="a")
    appendListToFile(log,("Finished",time.strftime("%Y/%m/%d %H:%M:%S")),mode="a") #Write finish time in log
except Exception as e:
    # If an error occurred, print( line number and error message
    import traceback, sys
    tb = sys.exc_info()[2]
    arcpy.AddMessage("Line:" + str(tb.tb_lineno)+ " Error " + e.message)
