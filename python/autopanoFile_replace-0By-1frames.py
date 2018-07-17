##Script para separar el archivo CSV en el formato separado por espacio y con los headers por separado.
import sys, os
import numpy
import re
import fileinput
import shutil
##Leer archivo y remplaza los Frames que terminan en -0.tif con -1.tif
##Para tener el archivo de mosaico autopano con las últimas 3 bandas
def replace(thefile):
  src=thefile #Get the input file name
  dst=thefile.replace("-0", "-1") #Copy fila and rename
  thefile1=shutil.copy(src, dst) #File to replace
  with fileinput.FileInput(thefile1, inplace=True) as file:
      for line in file:
          print(line.replace("-0.tif", "-1.tif"), end='')

#Script
for f in sys.argv[1:]: replace(f)

#######Opening XML files
# from xml.dom import minidom
# Test_file = open('C:/test_file.xml','r')
# xmldoc = minidom.parse(Test_file)

# Test_file.close()

# def printNode(node):
#   print node
#   for child in node.childNodes:
#        printNode(child)

# printNode(xmldoc.documentElement)