#Get subset of string based on a beginning char position and end position
import arcpy, os
def GetName(inputName):
    subsetName = inputName[fromChar:toChar]
    return subsetName

fromChar = arcpy.GetParameter(0)
toChar = arcpy.GetParameter(1)
inputName = arcpy.GetParameter(2)
resultString = GetName(inputName)

arcpy.SetParameterAsText(3, resultString )
arcpy.AddMessage("Original string: "+inputName )
arcpy.AddMessage("Truncated from: "+str(fromChar)+", to: "+str(toChar))
arcpy.AddMessage("Result string: "+ resultString )