##Script para separar el archivo CSV en el formato separado por espacio y con los headers por separado.
import sys, os
import numpy
import re
##Leer archivo
def toPNR(thefile):
  with open(thefile, 'rb') as f:
      contents=numpy.genfromtxt(f,delimiter=',',dtype=None,names=True)
      headers = contents.dtype.names
  print ('headers: {} '.format(headers))
  #print ('input file {}'.format(thefile))
  #print ('file {}'.format(str(contents)))
  basename = os.path.basename(thefile)
  print ('input basename {}'.format(basename))
  name =os.path.splitext(basename)[0]
  #Salvar datos con la extension . txt
  saveFile = os.path.join(os.getcwd(),name+'.txt')
  expr = re.compile("^b'|'$") #expresion
  with open(saveFile, 'w') as spaceFile:
    for i,line in enumerate(contents): #archivos con 1 solo registro?
      for item in line:
        #escribir linea y quitar los indicadores de tipo de dato "byte"
        spaceFile.write('%-25s' % (re.sub(expr, "", str(item))))
        #escribir nueva linea excepto al final
      if i!=(len(contents)-1): spaceFile.write('\n')
  #Salvar headers con la extension . pnr
  saveHeaders = os.path.join(os.getcwd(),name+'_HEADERS.txt')
  with open(saveHeaders, 'w') as spaceFile:
      for item in headers:
        spaceFile.write('%-25s' % (item))

#Script
for f in sys.argv[1:]: toPNR(f)
