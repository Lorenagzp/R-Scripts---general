import os
import re
import arcpy

try:
    workspace = "E:\\140415\\140415H\\mosaico"
    nombre_raster = "H140415_PA_1m_60bands"
    ext_raster = "dat"
    header_file = os.path.join(workspace, nombre_raster+".hdr")
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
        envi_header_keywords_or={"acquisition time|band names|bands|bbl|byte order|class lookup|class names|classes|cloud cover|complex function|coordinate system string|data gain values|data ignore value|data offset values|data reflectance gain values|data reflectance offset values|data type|default bands|default stretch|dem band|dem file|description|file type|fwhm|geo points|header offset|interleave|lines|map info|major frame offsets|minor frame offsets|pixel size|product type|projection info|read procedures|reflectance scale factor|rpc info|samples|security tag|sensor type|solar irradiance|spectra names|sun azimuth|sun elevation|wavelength|wavelength units|x start|y start|z plot average|z plot range|z plot titles"}

##    # Iterate over the lines of the file
    with open(header_file, 'rt') as f:
        dictio = {}
        data = f.read()[5:-1]
        #lines = re.split(r"[\n+]", data)

        #for i,l in enumerate(lines):
            #print str(i)+"-- "+str(l)
            #expresion to filter how to sepatate the string.
            #Look for regex wildcards for explanation or
            #the regex example at the end of this file            
        #regexpresion = re.compile(r"""(.+)\s*=\s*(.+)""")
        regexpresion = re.compile(r"""(.+)\s*=({.+}|[.+\n*]+)""")
        #dictio.update(dict(regexpresion.findall(data)))
        print regexpresion.findall(data)
        #for key in dictio: dictio[key]=dictio[key].strip()
        #for keyw in envi_header_keywords:
        #    if keyw in dictio:
        #        print "The keyword -"+keyw+"- in the header"
        #print dictio

except ValueError:
    print ValueError

#Examples

#regular expresion REGEX help example
##>>> r = "name: srek age :24 description: blah blah"
##>>> import re
##>>> regex = re.compile(r"\b(\w+)\s*:\s*([^:]*)(?=\s+\w+\s*:|$)")
##>>> d = dict(regex.findall(r))
##d
##{'age': '24', 'name': 'srek', 'description': 'blah blah'}
##Explanation:
## when the pattern is around these brackets() one separate value will be fetched by each () group  
##
##\b           # Start at a word boundary
##(\w+)        # Match and capture a single word (1+ alnum characters)
##\s*:\s*      # Match a colon, optionally surrounded by whitespace
##([^:]*)      # Match any number of non-colon characters
##(?=          # Make sure that we stop when the following can be matched:
## \s+\w+\s*:  #  the next dictionary key
##|            # or
## $           #  the end of the string
##)            # End of lookahead
    
