# -*- coding: utf-8 -*-
# Description:
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

# Import arcpy module
import os
import arcpy, arcgisscripting
import itertools
import re
import traceback, sys

 def zonalStatsMultiband(tableBaseName, bandNames, image, plot_polygons,id_field):
    #zonalStats iterated in all bands of the raster Multiband
    #Return list of the name of the generated tables
    tables=list()
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
            statsTable = tableBaseName+"B" + str(i)#+ ".dbf" #We add the band id to the StatsTable name
            #arcpy.AddMessage("Willbe stored in table "+str(statsTable))
            #Here we call the method to do the zonal statistics
            zs = arcpy.gp.ZonalStatisticsAsTable_sa(plot_polygons, id_field, band, statsTable, "DATA", "ALL")
            arcpy.AddMessage("resulting stats table: " + str(zs))
            tables.append(zs)
    else:
        #If we have just one band we call the raster without specifying any band
        zs = arcpy.gp.ZonalStatisticsAsTable_sa(plot_polygons, id_field, image, tableBaseName+"B1.dbf", "DATA", "ALL")
        tables.append(zs)
    arcpy.AddMessage("resulting stats table: " + str(zs))
    return tables
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

def write_hdr_file(hdr_filename,assign_bands=1,mode="w"):
    try:
        hdr_file = open(hdr_filename, mode)
        hdr_file.write("HEAD\nbands = "+ str(assign_bands))
        arcpy.AddMessage("writing in hdr file")
        hdr_file.close()
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print "OMG! Error while in: write_hdr_file"
        raise e
def write_txt_file(hdr_filename,mode="w",txt=""):
    try:
        hdr_file = open(hdr_filename, mode)
        hdr_file.write(txt)
        arcpy.AddMessage("writing in "+hdr_filename+" file")
        hdr_file.close()
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print "OMG! Error while in: write_txt_file"
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
    except Exception, e:
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print "OMG!"
        raise e    
def print_dict(dictio):
    #The next line iterates, formats and prints the dictionary, key:value
    #print "\n".join('{}={}'.format(k,v) for k,v in dictio.items()) print in console
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
            if deb==1: print str(i)+"-l- "+str(l)
            kwinfo+=l
            if deb==1: print str(i)+"-kwinfo- "+str(kwinfo)
            if ongoing==1:
                if "}" in l:
                    if deb==1: print "ongoing==se cierra por fin el parentesis"
                    print_kwinfo()
                    clines.append(kwinfo)
                    kwinfo=""
                    ongoing=0
                    continue
                else:
                    if deb==1: print "ongoing==1 else"
            if ongoing==0:
                ongoing=1
                for keyw in envi_header_keywords:
                    if keyw in l:
                        if deb==1: print keyw+" attribute found"
                        if "{" in l:
                            if "}" in l:
                                if deb==1: print "ongoing==parentesis cerrando en linea"
                                print_kwinfo()
                                clines.append(kwinfo)
                                kwinfo=""
                                ongoing=0
                            else:
                                if deb==1: print "if bracket in l: --- else"
                        else:
                            if deb==1: print "ongoing==sin paretesis"
                            print_kwinfo()
                            clines.append(kwinfo)
                            kwinfo=""
                            ongoing=0
            if deb==1: print "fin de ronda de for"
        for cl in clines:
            #expresion to filter how to sepatate the string.
            regexpresion = re.compile(r"""(.+?)\s*=\s*(.+)""")
            dictio.update(dict(regexpresion.findall(cl)))
            if deb==1: print regexpresion.findall(cl)
        for key in dictio: dictio[key]=dictio[key].strip()
        print "Header attributes:"
        arcpy.AddMessage("Header attributes read")
        print_dict(dictio)
        expr_replace = re.compile(r"{|}") #Expression to remove brackets below
        #wavelength
        if "wavelength" in dictio:
            wl=re.split(r"[,]", dictio["wavelength"])
            wl =replace_in_list(expr_replace,wl)
            arcpy.AddMessage(wl)
            arcpy.AddMessage("saved wl")
        #Number of Bands
        if "bands" in dictio:
            hdr_bands=dictio["bands"]
            arcpy.AddMessage(hdr_bands)
            arcpy.AddMessage("saved Number of bands from header")
        #Band names
        if "band names" in dictio:
            arcpy.AddMessage("band names attribute found")
            bn=re.split(r"[,]", dictio["band names"])
            arcpy.AddMessage("split competed")
            bn=replace_in_list(expr_replace,bn)
            arcpy.AddMessage("saved bn")
        #Next we add the wl units only if they are defined
        arcpy.AddMessage("Format composed band name")
        full_bn=hdr_bands #We assign by default the number of bands in the raster
        if "wavelength units" in dictio:
            if "band names" in dictio and "wavelength" in dictio:
                join_str = '{bandn} ({waveln} '+dictio["wavelength units"]+')' if dictio["wavelength units"]!="Unknown" else '{bandn} ({waveln})'
                arcpy.AddMessage("bn and wl found")
                full_bn= '\n'.join(join_str.format(bandn=b, waveln=w) for b,w in itertools.izip(bn, wl)).split('\n')
            if not "band names" in dictio and "wavelength" in dictio:
                join_str = '{waveln} '+dictio["wavelength units"] if dictio["wavelength units"]!="Unknown" else '{waveln}'
                arcpy.AddMessage("wl found+units")
                full_bn= '\n'.join(join_str.format(waveln=w) for w in wl).split('\n')
        else:
            if "band names" in dictio and "wavelength" in dictio:
                join_str = '{bandn} ({waveln})'
                arcpy.AddMessage("bn and wl found")
                full_bn= '\n'.join(join_str.format(bandn=b, waveln=w) for b,w in itertools.izip(bn, wl)).split('\n')
            if not "band names" in dictio and "wavelength" in dictio:
                arcpy.AddMessage("wl found")
                full_bn= wl
        arcpy.AddMessage(full_bn)
        if deb==1:
            print full_bn
            print "Bands descripted in header: "+len(full_bn)
        arcpy.AddMessage("Finished reading header") 
        #arcpy.AddMessage(type(full_bn)) #to know the type of variable it was created
        return full_bn
    except Exception, e:
        # If an error occurred, print line number and error message
        import traceback, sys
        tb = sys.exc_info()[2]
        arcpy.AddMessage("Line:" + str(tb.tb_lineno))
        arcpy.AddMessage("Error " + e.message)
        print "OMG!"
        raise e
    
##--------------------------------- Starts the script
try:
    # Check out any necessary licenses and Create the Geoprocessor object
    arcpy.CheckOutExtension("spatial")
    gp = arcgisscripting.create()
    #START----------------Get Input parameters
    #Type: Feature layer -buffer for the zonalStats
    plot_polygons = arcpy.GetParameterAsText(0)
    arcpy.AddMessage("read b1 " + plot_polygons)
    print plot_polygons
    arcpy.AddMessage("read " + plot_polygons)
    desc = arcpy.Describe(plot_polygons)
    gPath = desc.path
    gridSource = str(gPath)
    arcpy.AddMessage("Grid source: " + gridSource)
    gridName = desc.baseName
    gridTrial = desc.baseName[0:3]#Framer's Field or trial that this buffer is representing
    gridFeatures = desc.baseName[9:12]#What feature of that trial field is the grid representing: plots, buffered plots, dissolved plots, etc
    arcpy.AddMessage("Grid basename: " + gridName)
    print plot_polygons
    #type: image layer
    image = arcpy.GetParameterAsText(1)
    arcpy.AddMessage("read " + image)
    desc = arcpy.Describe(image)
    rPath = desc.path
    rdate = desc.baseName[1:7] #Get the date from the raster to create the save feature
    r_img = desc.baseName[0:1] #Get the image id from the raster to create the save feature
    trialName = desc.baseName[7:10] #Get the trial id from the raster to create the save feature
    image = str(rPath) + "\\" + desc.baseName+ "." +desc.extension
    rname = desc.baseName
    arcpy.AddMessage("image source: " + image)
    print image
    #type: Field - Field for statistics
    id_field = arcpy.GetParameterAsText(2)
    arcpy.AddMessage("read " + id_field)
    #tablesPath: tablesPath - GDB where to save the statistics tables
    tablesPath = arcpy.GetParameterAsText(3)
    arcpy.AddMessage("GDB where to save the statistics tables: " + tablesPath) 
    #KnownBands: Known number of bands in case there is no header file
    #Optional, but set to default as 1 if there is no header file
    knownBands = arcpy.GetParameterAsText(4)
    arcpy.AddMessage("known number of Bands: " + str(knownBands))
    #ENDS---------------------Input parameters
    #Reading header to get Bands
    #We assume header file is there and named as the raster
    hdr_file = os.path.join(str(rPath) + "\\" + rname+".hdr") 
    #Read header to know number and name of bands or set them a priori
    #knownBands is optional
    bandNames = readHeaderFile(hdr_file, knownBands)
    tableBaseName = tablesPath + "\\"+r_img+rdate+gridTrial+gridFeatures #stats table base name
    zonalStatsMultiband(tableBaseName, bandNames, image, plot_polygons,id_field) #do the zs
    f="Finish"
    print f
    arcpy.SetParameterAsText(5,f)
except Exception, e:
    # If an error occurred, print line number and error message
    import traceback, sys
    tb = sys.exc_info()[2]
    arcpy.AddMessage("Line:" + str(tb.tb_lineno) + "Error " + e.message)