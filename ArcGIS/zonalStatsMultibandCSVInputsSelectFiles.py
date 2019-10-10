#Perform zonal statistics tool based on a list of on a specified list of dates and names.
#The inputs are specified as para meters in the tool in ArcMap
#Automatically calls the appropriate raster and zonal data from the specified locations.
#Assumes the default "Greenplane" naming standards

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

# image:  data image to use as input for zonal statistic tool.
#   Standard file name system on the raster is espected: xYYMMDDtttsss
#   Being:
#   x = [h,m,t,c,a,r,n] one char representing the camera used to acquire the imagery
    #   sss = 3 char representing the processing stage of the imagery. E.g. "geo" for georeferenced, "pno" for the multi mosaic  
#   The band information is read from the envi HDR file

# Workspace: where to save the statistics tables and where to create the features to save the mean values per plot

# Known bands: [Optional] Number of bands of the input raster. Necessary if
#   the header file doesn't exist -> default is 1 if not specified.

#(ouput)
# Tables: The full default statistics table
#   Table name structure: xYYMMDDtttfffBi
#   Being:
#   i: the band number from which the statistics was calculated based on the zones of the input feature
# ---------------------------------------------------------------------------

#################################WARNING
#crashes if the csv (of the extraction list) has just one row

from functions_extraction import * 
        
try:      
    # Check out any necessary licenses and Create the Geoprocessor object
    arcpy.CheckOutExtension("spatial")
    gp = arcgisscripting.create()
    #########################################################################################
    ################################# START:INPUTS ##########################################
    #Hard coded this
    csvExtractThis = arcpy.GetParameterAsText(0)
    #imgWs="G:\\AD15_16\\" #imageBaseLocation
    imgWs = arcpy.GetParameterAsText(6) #test
    # FOLDER STRUCTURE ###### IMPORTANT!!! : Got to line 122 to choose a, b or c, depending on the folder structure to look for. Read its comments.
    #GDB whare the feature classes are stored and where the tables will be written:
    gdb = arcpy.GetParameterAsText(1) #BW
    #gdb = "C:\\Users\\usuario\\Documents\\ArcGIS\\Default.gdb\\" #Default
    #tws = where to save tables inside the workspace
    tws =arcpy.GetParameterAsText(9)######Not worinkg... it saves a folder up#######
    ds=arcpy.GetParameterAsText(3) #Use this ds="" fro m and t
    #ds="h" #Use this for hyper
    arcpy.env.workspace = gdb
    #arcpy.AddMessage("wspace: "+str(arcpy.env.workspace))
    #knownBands="62" # ##################### hyper resampled
    knownBands=arcpy.GetParameterAsText(8) # ####################### thermal
    id_field = arcpy.GetParameterAsText(5) #Table field that has the unique plot identifier
    log= arcpy.GetParameterAsText(10)
    ## END:INPUTS ##

    ## START:VARIABLES ##
    #Get all feature classes gdb/extract dataset
    listFc = arcpy.ListFeatureClasses(
        feature_type="Polygon",
        feature_dataset=ds)
    mosaicFolder = {
        #Get the folder and suffix for the images according to the camera
        #"m": ("geo","mkd"), #When you will use the masked rasters
        "m": ("geo","geo"), #When you will use the original multispectral rasters
        "q": ("rfl","rfl"), #When you will use the sequoia multispectral rasters
        "h": ("rfl_spr_ort","ort"),
        #"h": ("rfl_spr_ort","rfl"),
        "t": ("cel","cel")#, #This to extract from the full mosaic
        #"t": ("4_index\\indices\\cel","_index_cel") #This to get the images from the pix4d project indices folder
        #"t": ("msk","mkd"), #This to extract from the masked mosaic
    }
    arcpy.env.workspace = gdb
    ext=arcpy.GetParameterAsText(7) #extension of the rasters
    buf=arcpy.GetParameterAsText(2) #we use the buffered plot features -buf- to extract the stats or the full plots -plt-
    bw8=arcpy.GetParameterAsText(4) #default trial eg. bw8 if there is a raster that includes all the zonal features

    ####################################
    ############################ END:VARIABLES ##############################################
    #########################################################################################
    ex, dates,trials = readWhatToExtract(csvExtractThis)
    #find the image paths and features to perform the zonal statistics
    for f, flightdate in enumerate(ex):
        for t,trial in enumerate(flightdate): #skip the date column
            for cam in trial.split():
                cam = cam.decode("UTF-8") #deal with the encoding
                if cam !="-":
                #Qué hacer si está vacío?    
                    #ZONES FEATURE
                    #Search for the corresponding grids for this date/trial/cam
                    #if date is __ad__ the grid is the general for the cycle e.g. ypt__ad__buf
                    #if date is YYMMDD the grid was adjusted, and needs to have indicated also the camera
                    #   this way we can know at which image the adjustment corresponds.
                    #   grids adjusted will be like bw1160215bufh -> with the date and camera indicated
                    #arcpy.AddMessage(str(trials[t]))
                    #arcpy.AddMessage(str(dates[f]))
                    #arcpy.AddMessage(buf)
                    #arcpy.AddMessage(cam.decode("UTF-8"))
                    pattern = str(trials[t])+"("+str(dates[f])+"|__ag__)"+buf+"["+str(cam)+"]*$"#################################################this is hardcoded year code cycle
                    arcpy.AddMessage("pattern: "+str(pattern))
                    #arcpy.AddMessage("FList: "+str(listFc)) #print List of features selected
                    plotsF = [ft for ft in listFc if re.search(pattern, ft)]
                    #Will throw error if list empty?
                    if plotsF:
                        if len(plotsF)>1: plotsF=plotsF[0] #get just the edited feature if the general exists
                        plotsF=os.path.join(arcpy.env.workspace, ds, ''.join(plotsF))
                        arcpy.AddMessage("Zones: "+plotsF)
                        #RASTER
                        #search for the images that match them
                        #   hyper mosaics folder is rfl_spr_ort, for multi is geo, for thermal is cel
                        mF, sx = mosaicFolder.get(cam,("rfl","rfl")) #corresponding folder and sfx, geo default
                        pix4projname = str(cam)+str(dates[f])+str(trials[t]) # Use if the imagery was processed with pix4D (t)                                
                        #imgLocation = imgWs+"\\"+str(dates[f])+"\\"+cam+"\\"+pix4projname+"\\"+mF+"\\" # Location if processed with pix4d (t)          ### Choose a: Use these if will use for copying imagery processed with Pix4D
                        imgLocation = imgWs+"\\"+str(dates[f])+"\\"+str(cam)+"\\"+mF+"\\" # Default greenplane structure location (h, m)                     ### Choose b:  Use this tipically for m, h
                        #imgLocation = imgWs+"\\" #For all pictures in the same folder                                                                  ### Choose c: to just get them all from the base WD folder.
                        imgName =str(cam)+str(dates[f])+str(trials[t])+sx+ext
                        img=imgLocation+imgName
                        arcpy.AddMessage("looking for raster for area: "+str(img)) #print to check
                        if not exists(img): #Use the general mosaic
                            imgName =str(cam)+str(dates[f])+bw8+sx+ext
                            img=imgLocation+imgName
                            arcpy.AddMessage("looking for general mosaic: "+str(img)) #print to check
                        if exists(img):
                            arcpy.AddMessage("Raster: "+img)
                            #PREPARE FOR THE ZS
                            #Reading header to get Bands
                            #We assume header file is there and named as the raster
                            hdr_file = img[:-4]+".hdr"
                            #Read header to know number and name of bands or set them a priori
                            #knownBands is optional
                            bandNames = readHeaderFile(hdr_file, knownBands)
                            tableBaseName = arcpy.ValidateTableName(str(cam)+str(dates[f])+str(trials[t])+buf,tws) #stats table base name in ws
                            #arcpy.AddMessage("zs")
                            #arcpy.AddMessage("tb:"+tableBaseName)
                            zsm = zonalStatsMultiband(tableBaseName, bandNames, img, plotsF,id_field)
                            appendListToFile(log,zsm,mode="a")
                        else:
                            arcpy.AddMessage("|||No raster to use |||")
                            appendListToFile(log,str(img),mode="a")
                    else:
                        arcpy.AddMessage("|||No features to use|||")
                        appendListToFile(log,str(plotsF),mode="a")
                else: arcpy.AddMessage("No data extracting for this trial on this date")
    appendListToFile(log,("Finished",time.strftime("%Y/%m/%d %H:%M:%S")),mode="a") #Write finish time in log
except Exception as e:
    # If an error occurred, print( line number and error message
    import traceback, sys
    tb = sys.exc_info()[2]
    arcpy.AddMessage("Line:" + str(tb.tb_lineno)+ " Error " + e.message)