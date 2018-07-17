import re
import arcpy
import itertools
import os

def print_kwinfo():
    if deb==1:
        print "kwinfo se guarda:"
        print kwinfo

def replace_in_list(regex,lst):
    return [re.sub(regex, '', x).strip() for x in lst] #List comprehension

def print_dict(dictio):
    #The next line iterates, formats and prints the dictionary, key:value
    print "\n".join('{}={}'.format(k,v) for k,v in dictio.items())

def letsgo(header_file):
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
        data = f.read()[5:]
    lines = re.split(r"[\n]", data)#the info corresponding to one line
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
    print_dict(dictio)
    #Now we save to a list what the wavelengt name info
    expr_replace = re.compile(r"{|}") #Expression to remove brackets below
    #wavelength
    wl=re.split(r"[,]", dictio["wavelength"])
    wl =replace_in_list(expr_replace,wl)
    #Band names
    bn=re.split(r"[,]", dictio["band names"])
    bn=replace_in_list(expr_replace,bn)
    #Next we add the wl units only if they are defined
    join_str = '"{bandn} ({waveln} '+dictio["wavelength units"]+')"' if dictio["wavelength units"]!="Unknown" else '"{bandn} ({waveln})"'
    full_bn= '\n'.join(join_str.format(bandn=b, waveln=w) for b,w in itertools.izip(bn, wl)).split('\n')
    if deb==1:
        print full_bn
        print "Bands: "+len(full_bn)
    return full_bn
        
##        Starts the script
try:
    workspace = "E:\\140328\\140328H\\mosaico"
    nombre_raster = "H140328_PA_1m_60bands"
    hdr_file = os.path.join(workspace, nombre_raster+".hdr")        
    print letsgo(hdr_file)
except ValueError:
    print ValueError
