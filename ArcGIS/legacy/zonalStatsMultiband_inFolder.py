#Perform zonal statistics tool in all the imagery on a folder.
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
#crashes if the csv has just one row

import numpy
import os
import arcpy, arcgisscripting
import itertools
import re
import traceback, sys
import time

#Read the file to know which feature-raster to extract
def readWhatToExtract(csvWhatToExtract):
    arcpy.AddMessage("will read file: "+csvWhatToExtract)
    extractMatrix=numpy.genfromtxt(open(csvWhatToExtract,"rb"),
        delimiter=',',
        dtype=None,
        names=True)
    dates = list(extractMatrix['date']) #get the dates
    arcpy.AddMessage("Dates: "+str(dates))
    trials=extractMatrix.dtype.names[1:]
    arcpy.AddMessage("Trials: "+str(trials))
    extractMatrix = extractMatrix[list(extractMatrix.dtype.names)[1:]]#remove "date" column (1st)
    arcpy.AddMessage("What to extract: "+str(extractMatrix))
    return extractMatrix,dates,trials
    #Return the matrix of the kind of images acquired on each day on each trial [h m t],
    #the list of dates and the list of trials (removing the "date" item)
def readDbf():# read dbf file
    print("Algo haremos aquí")# zsFields= ["id","COUNT","MEAN","STD"]
    # table="C:\\Users\\usuario\\Documents\\ArcGIS\\m150326pcwbufB1.dbf"
    # with arcpy.da.SearchCursor(table, zsFields) as cursor:
    #     for row in cursor:
    #         print(('Feature {0} has an area of {1}'.format(row[0], row[1]))
def zonalStatsMultiband(tableBaseName, bandNames, image, plot_polygons,id_field):
    try:
        tables=list()
        #zonalStats iterated in all bands of the raster Multiband
        #Return list of the name of the generated tables
        arcpy.AddMessage("Iterating the zonal statistics across all bands...")
        #Get bands
        #Returns: [0]numberOfBands, [1]isBandNamesInteger?
        numOfBands = getNumberOfBands(bandNames)
        arcpy.AddMessage("Number of bands: "+str(numOfBands[0]))
        #If the image has more than one band...
        if numOfBands[0] != 1:
            #If we only have the number of bands, but no band names (because there was no hdr)...
            #We will call the bands by the default way ArcMap does: RasterName + Band_1, Band_2, etc...
            #we create the list to iterate it
            if numOfBands[1]: bandNames = list('Band_%s' % b for b in range(1, numOfBands[0]+1))
            #Here iterates through the bands and runs the zonal statistics tool
            #Get the count with the function "enumerate"
            for i, b in enumerate(bandNames, start=1):
                #Next we add the band name to the raster basename
                band = image + "\\" + b
                arcpy.AddMessage("Iterating band # "+ str(i)+" - " + band)
                #Set table name
                statsTable = tableBaseName+"B" + str(i)+ ".dbf" #We add the band id to the StatsTable name
                #arcpy.AddMessage("Willbe stored in table "+str(statsTable))
                #Here we call the method to do the zonal statistics
                zs = arcpy.gp.ZonalStatisticsAsTable_sa(plot_polygons, id_field, band, statsTable, "DATA", "ALL")
                arcpy.AddMessage("resulting stats table: " + str(zs))
                tables.append(plot_polygons+","+band+","+str(zs))
        else:
            #If we have just one band we call the raster without specifying any band
            zs = arcpy.gp.ZonalStatisticsAsTable_sa(plot_polygons, id_field, image, tableBaseName+"B1.dbf", "DATA", "ALL")
            tables.append(plot_polygons+","+image+","+str(zs))
        arcpy.AddMessage("||| resulting zs table: " + str(zs))
        return tables
    except Exception as e:
        # If an error occurred, print( line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
def print_kwinfo():
    if deb==1:
        print( "kwinfo se guarda:")
        print( kwinfo)

def create_if_not_exists(path):
    try:
        if not os.path.exists(path):
            os.makedirs(path)
    except Exception as e:
        # If an error occurred, print( line number and error message
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)

def exists(path):
    exists = True if os.path.exists(path) else False
    return exists 

def write_hdr_file(hdr_filename,assign_bands=1,mode="w"):
    try:
        hdr_file = open(hdr_filename, mode)
        hdr_file.write("HEAD\nbands = "+ str(assign_bands)+"\n")
        arcpy.AddMessage("writing in hdr file")
        hdr_file.close()
    except Exception as e:
        # If an error occurred, print( line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print( "OMG! Error while in: write_hdr_file")
        raise e
def appendListToFile(txt_filename,thelist,mode="w"):
    try:
        file = open(txt_filename, mode)
        #arcpy.AddMessage("writing in "+txt_filename+" file")
        for item in thelist:
            file.write("%s\n" % item)
        file.close()
    except Exception as e:
        # If an error occurred, print( line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print( "OMG! Error while in: appendListToFile")
        raise e

def replace_in_list(regex,lst):
    return [re.sub(regex, '', x).strip() for x in lst] #List comprehension
#Method to concatenate the band name to the raster basename
#BandNames has or all the list of band names or the number of bands
def getNumberOfBands(bandNames):
    try:
        #If there was no bandnames or header, a band number was assigned
        #This would be an integer
        numOfBands = int(bandNames)
        isANumber = True
        return numOfBands, isANumber
    except ValueError:
        #If there is a band name as a string we will say it's one band
        numOfBands = 1
        isANumber = False
        return numOfBands, isANumber
    except TypeError:
        #If there are band names as list or array we will count them here
        numOfBands = len(bandNames)
        isANumber = False
        return numOfBands, isANumber        
    except Exception as e:
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print( "OMG!")
        raise e    
def print_dict(dictio):
    #The next line iterates, formats and prints the dictionary, key:value
    #print( "\n".join('{}={}'.format(k,v) for k,v in dictio.items()) print( in console
    arcpy.AddMessage("\n".join('{}={}'.format(k,v) for k,v in dictio.items()))#Print to arcmap results window   
def readHeaderFile(header_file,assign_bands=1):
    try:
        if not exists(header_file):
            write_hdr_file(header_file,assign_bands)
            arcpy.AddMessage("Header not found, it was created a basic one. Number of bands assigned: "+str(assign_bands))
        arcpy.AddMessage("started reading header file:" + str(header_file))
        envi_header_keywords={"acquisition time","band names","bands",
                              "bbl","byte order","class lookup","class names",
                              "classes","cloud cover","complex function",
                              "coordinate system string","data gain values",
                              "data ignore value","data offset values",
                              "data reflectance gain values","data reflectance offset values",
                              "data type","default bands","default stretch","dem band",
                              "dem file","description","file type","fwhm","geo points",
                              "header offset","interleave","lines","map info",
                              "major frame offsets","minor frame offsets","pixel size",
                              "product type","projection info","read procedures",
                              "reflectance scale factor","rpc info","samples","security tag",
                              "sensor type","solar irradiance","spectra names","sun azimuth",
                              "sun elevation","wavelength","wavelength units","x start",
                              "y start","z plot average","z plot range","z plot titles"}
        envi_header_keywords_or="|".join(envi_header_keywords)
        # Read and Iterate over the lines of the file
        with open(header_file, 'rt') as f:
            data = f.read()[5:] #Skip the first "ENVI" letters of the header
        lines = re.split(r"[\n]", data)#the info corresponding to one line
        arcpy.AddMessage("reading header lines...")
        dictio = {}
        global deb
        deb=0
        wl=[]#List to save wavelengths
        bn=[]#List to save band names
        clines=[]#complete lines with all the info corresponding to one header keyword
        ongoing=0 #Variable para marcar si se está buscando el resto de la línea de info
        #to one header keyword is not in one single line
        kwinfo=""
        for i,l in enumerate(lines):
            if deb==1: print( str(i)+"-l- "+str(l))
            kwinfo+=l
            if deb==1: print( str(i)+"-kwinfo- "+str(kwinfo))
            if ongoing==1:
                if "}" in l:
                    if deb==1: print( "ongoing==se cierra por fin el parentesis")
                    print_kwinfo()
                    clines.append(kwinfo)
                    kwinfo=""
                    ongoing=0
                    continue
                else:
                    if deb==1: print( "ongoing==1 else")
            if ongoing==0:
                ongoing=1
                for keyw in envi_header_keywords:
                    if keyw in l:
                        if deb==1: print( keyw+" attribute found")
                        if "{" in l:
                            if "}" in l:
                                if deb==1: print( "ongoing==parentesis cerrando en linea")
                                print_kwinfo()
                                clines.append(kwinfo)
                                kwinfo=""
                                ongoing=0
                            else:
                                if deb==1: print( "if bracket in l: --- else")
                        else:
                            if deb==1: print( "ongoing==sin paretesis")
                            print_kwinfo()
                            clines.append(kwinfo)
                            kwinfo=""
                            ongoing=0
            if deb==1: print( "fin de ronda de for")
        for cl in clines:
            #expresion to filter how to sepatate the string.
            regexpresion = re.compile(r"""(.+?)\s*=\s*(.+)""")
            dictio.update(dict(regexpresion.findall(cl)))
            if deb==1: print( regexpresion.findall(cl))
        for key in dictio: dictio[key]=dictio[key].strip()
        print( "Header attributes:")
        #arcpy.AddMessage("Header attributes read")
        #print_dict(dictio)
        expr_replace = re.compile(r"{|}") #Expression to remove brackets below
        #wavelength
        if "wavelength" in dictio:
            wl=re.split(r"[,]", dictio["wavelength"])
            wl =replace_in_list(expr_replace,wl)
            #arcpy.AddMessage(wl)
            #arcpy.AddMessage("saved wl")
        #Number of Bands
        if "bands" in dictio:
            hdr_bands=dictio["bands"]
            #arcpy.AddMessage(hdr_bands)
            #arcpy.AddMessage("saved Number of bands from header")
        #Band names
        if "band names" in dictio:
            #arcpy.AddMessage("band names attribute found")
            bn=re.split(r"[,]", dictio["band names"])
            #arcpy.AddMessage("split completed")
            bn=replace_in_list(expr_replace,bn)
            #arcpy.AddMessage("saved bn")
        #Next we add the wl units only if they are defined
        #arcpy.AddMessage("Format composed band name")
        full_bn=hdr_bands #We assign by default the number of bands in the raster
        if "wavelength units" in dictio:
            if "band names" in dictio and "wavelength" in dictio:
                join_str = '{bandn} ({waveln} '+dictio["wavelength units"]+')' if dictio["wavelength units"]!="Unknown" else '{bandn} ({waveln})'
                #arcpy.AddMessage("bn and wl found")
                full_bn= '\n'.join(join_str.format(bandn=b, waveln=w) for b,w in itertools.izip(bn, wl)).split('\n')
            if not "band names" in dictio and "wavelength" in dictio:
                join_str = '{waveln} '+dictio["wavelength units"] if dictio["wavelength units"]!="Unknown" else '{waveln}'
                #arcpy.AddMessage("wl found+units")
                full_bn= '\n'.join(join_str.format(waveln=w) for w in wl).split('\n')
        else:
            if "band names" in dictio and "wavelength" in dictio:
                join_str = '{bandn} ({waveln})'
                #arcpy.AddMessage("bn and wl found")
                full_bn= '\n'.join(join_str.format(bandn=b, waveln=w) for b,w in itertools.izip(bn, wl)).split('\n')
            if not "band names" in dictio and "wavelength" in dictio:
                #arcpy.AddMessage("wl found")
                full_bn= wl
        #arcpy.AddMessage(full_bn)
        if deb==1:
            arcpy.AddMessage( full_bn)
            arcpy.AddMessage( "Bands descripted in header: "+len(full_bn))
        #CHECK IF the "data ignore value is set", otherwise, set it to 0.
        if not "data ignore value" in dictio:
            arcpy.AddMessage("Set -data ignore value to 0-")
            add=["data ignore value = 0"]
            appendListToFile(header_file,add,mode="a")
        #arcpy.AddMessage("Finished reading header") 
        #arcpy.AddMessage(type(full_bn)) #to know the type of variable it was created
        return full_bn
    except Exception as e:
        # If an error occurred, print( line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print( "OMG!")
        raise e
#^^^^^^^^^^^^^^^^^^^^^^^ Methods ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
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
        #"m": ("msk","mkd"), #When you will use the masked rasters
        "m": ("geo","geo"), #When you will use the original multispectral rasters
        #"h": ("rfl_spr_ort","ort"),
        "h": ("rfl_spr_ort","rfl"), #Specific for this test
        "t": ("cel","cel"), #This to extract from the full mosaic
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
                if cam !="-":
                #Qué hacer si está vacío?    
                    #ZONES FEATURE
                    #Search for the corresponding grids for this date/trial/cam
                    #if date is __ad__ the grid is the general for the cycle e.g. ypt__ad__buf
                    #if date is YYMMDD the grid was adjusted, and needs to have indicated also the camera
                    #   this way we can know at which image the adjustment corresponds.
                    #   grids adjusted will be like bw1160215bufh -> with the date and camera indicated
                    pattern = str(trials[t])+"("+str(dates[f])+'|__ae__)'+buf+'['+cam+']*$'#################################################this is hardcoded year code cycle
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
                        mF, sx = mosaicFolder.get(cam,("geo","geo")) #corresponding folder and sfx, geo default ##Use this to search in dates folders
                        #imgLocation = imgWs+"\\"+str(dates[f])+"\\"+cam+"\\"+mF+"\\" ##Use this to search in dates folders
                        imgLocation = imgWs+"\\"+cam+"\\" #This to search in the base folder + cam
                        imgName =cam+str(dates[f])+str(trials[t])+sx+ext
                        img=imgLocation+imgName
                        arcpy.AddMessage("looking for raster for area: "+str(img)) #print to check
                        if not exists(img): #Use the general mosaic
                            imgName =cam+str(dates[f])+bw8+sx+ext
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
                            tableBaseName = arcpy.ValidateTableName(cam+str(dates[f])+str(trials[t])+buf,tws) #stats table base name in ws
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