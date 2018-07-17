'''-------------------------------------------------------------------------------------------
 Tool Name:   Polygon Bisector
 Source Name: polygonbisector.py
 Version:     ArcGIS 10.0
 Author:      ESRI, Inc.
 Required Arguments:
              Input Features (Feature Layer)
              Output Feature Class (Feature Class)
 Optional Arguments:
              Axis (X|Y)
              Group Field(s) (Field)
              Acceptable Error Percent (Double)

 Description: Computes a line that bisects, or divides in half, a polygon area along a line
              of constant latitude or longitude. Half of each input polygon's area will be
              on either side of the bisecting line.
----------------------------------------------------------------------------------------------'''

# Import system modules
import arcpy
import os
import sys
import math

# Main function, all functions run in GravityModel
def PolygonBisector(in_features, out_fc, axis="x", groupfields=[], error=0.001):
    # Error if sufficient license is not available
    if arcpy.ProductInfo().lower() not in ['arcinfo']:
        arcpy.AddError("An ArcInfo/Advanced license is required.")
        sys.exit()

	# Set geoprocessing environments
    arcpy.env.overwriteOutput = True
    arcpy.env.qualifiedFieldNames = False

    shapefield = arcpy.Describe(in_features).shapeFieldName
    rounder = GetRounder(in_features)

    # If group fields are specified, dissolve by them
    if groupfields:
        in_features = arcpy.management.Dissolve(in_features, "in_memory/grouped", groupfields)
    else:
        groupfields = [arcpy.Describe(in_features).OIDFieldName]
    fields = [shapefield] + groupfields

    # Create output feature class and set up cursor
    icur = irow = scur = None
    arcpy.management.CreateFeatureclass(os.path.dirname(out_fc), os.path.basename(out_fc), "POLYLINE", "", "", "", arcpy.Describe(in_features).spatialReference)
    arcpy.management.AddField(out_fc, "Group_", "TEXT", "", "", "", "Group: {0}".format(", ".join(groupfields)))
    icur = arcpy.InsertCursor(out_fc)
    scur = arcpy.SearchCursor(in_features, "", "", ";".join(fields))
    count = int(arcpy.management.GetCount(in_features).getOutput(0))
    arcpy.SetProgressor("step", "Processing polygons...", 0, count, 1)
    bigi = 1

    # Begin processing
    try:
        for row in scur:
            minx = miny = float("inf")
            maxx = maxy = float("-inf")
            totalarea = 0
            feat = row.getValue(shapefield)
            totalarea = row.getValue(shapefield).area
            group = []
            for field in groupfields:
                group.append(str(row.getValue(field)))
            partnum = 0
            # Get the min and max X and Y
            for part in feat:
                for point in feat.getPart(partnum):
                    if point:
                        minx = point.X if point.X < minx else minx
                        miny = point.Y if point.Y < miny else miny
                        maxx = point.X if point.X > maxx else maxx
                        maxy = point.Y if point.Y > maxy else maxy
                partnum += 1

            # Process the polygon
            # Some variables
            conditionmet = False
            difference = 0
            lastdifference = float("inf")
            differences = {}
            itys = {}
            i = 1
            strike = 0

            # The starting bisector (half the distance from min to max)
            if axis == "x":
                ity = (miny + maxy)/2.0
            else:
                ity = (minx + maxx)/2.0

            while not conditionmet:
                # Construct a line through the middle
                if axis == "x":
                    line = MakeBisector(minx, maxx, ity, in_features, axis)
                else:
                    line = MakeBisector(miny, maxy, ity, in_features, axis)
                # The FeatureToPolygon function does not except a geometry object, so make a temporary feature class
                templine = arcpy.management.CopyFeatures(line, "in_memory/templine")
                temppoly = arcpy.management.CopyFeatures(feat, "in_memory/temppoly")
                # Intersect then Feature To Polygon
                bisected = arcpy.management.FeatureToPolygon([temppoly, templine], "in_memory/bisected")
                clip = arcpy.analysis.Clip(bisected, in_features, "in_memory/clip")

                # Group bisected polygons according to above or below the bisector
                arcpy.management.AddField(clip, "FLAG", "SHORT")
                ucur = arcpy.UpdateCursor(clip, "", "")
                flag = 0
                try:
                    for urow in ucur:
                        ufeat = urow.getValue(arcpy.Describe(clip).shapeFieldName)
                        partnum = 0
                        for upart in ufeat:
                            for upoint in ufeat.getPart(partnum):
                                if upoint:
                                    if axis == "x":
                                        if round(upoint.Y, rounder) > round(ity, rounder):
                                            flag = 1
                                            break
                                        elif round(upoint.Y, rounder) < round(ity, rounder):
                                            flag = -1
                                            break
                                    else:
                                        if round(upoint.X, rounder) > round(ity, rounder):
                                            flag = 1
                                            break
                                        elif round(upoint.X, rounder) < round(ity, rounder):
                                            flag = -1
                                            break
                            partnum += 1
                        urow.setValue("FLAG", flag)
                        ucur.updateRow(urow)
                except:
                    raise
                finally:
                    if ucur:
                        del ucur

                # Check if the areas are halved
                dissolve = arcpy.management.Dissolve(clip, "in_memory/dissolve", "FLAG")
                scur2 = arcpy.SearchCursor(dissolve)
                try:
                    for row2 in scur2:
                        firstarea = row2.getValue(arcpy.Describe(dissolve).shapeFieldName).area
                        firstflag = row2.getValue("FLAG")
                        break
                except:
                    raise
                finally:
                    if scur2:
                        del scur2

                # #################################################################
                # Modify the Y of the line (move it up or down) to resize the split
                # #################################################################
                difference = abs(firstarea - (totalarea/2.0))
                differences[i] = difference
                itys[i] = ity
                print round(100*(difference/(totalarea/2.0)),5)
                #arcpy.AddWarning(round(100*(difference/(totalarea/2.0)),5))
                # Stop if tolerance is achieved
                if (difference/(totalarea/2.0))*100 <= error:
                    conditionmet = True
                    break
                # Moving the line in the wrong direction? due to coordinate system origins or over-compensation
                if difference > lastdifference:
                    firstflag = firstflag*-1.0
                # If we're not improving
                if abs(difference) > min(differences.values()):
                    strike+=1
                # Or if the same values keep appearing
                if differences.values().count(difference) > 3 or strike >=3:
                    arcpy.AddWarning("Tolerance could not be achieved. Output will be the closest possible.")
                    # Reconstruct the best line
                    if axis == "x":
                        line = MakeBisector(minx, maxx, itys[min(differences,key = lambda a: differences.get(a))], in_features, axis)
                    else:
                        line = MakeBisector(miny, maxy, itys[min(differences,key = lambda a: differences.get(a))], in_features, axis)
                    break
                # Otherwise move the bisector so that the areas will be more evenly split
                else:
                    if firstflag == 1:
                        if axis == "x":
                            ity = ((ity-miny)/((totalarea/2.0)/firstarea)) + miny
                        else:
                            ity = ((ity-minx)/((totalarea/2.0)/firstarea)) + minx
                    elif firstflag == -1:
                        if axis == "x":
                            ity = ((ity-miny)*math.sqrt((totalarea/2.0)/firstarea)) + miny
                        else:
                            ity = ((ity-minx)*math.sqrt((totalarea/2.0)/firstarea)) + minx
                    lastdifference = difference
                i +=1
            irow = icur.newRow()
            irow.setValue(arcpy.Describe(out_fc).shapeFieldName, line)
            irow.setValue("Group_", ", ".join(group))
            icur.insertRow(irow)
            arcpy.SetProgressorPosition()
            arcpy.AddMessage("{0}/{1}".format(bigi, count))
            bigi +=1

    except:
        if arcpy.Exists(out_fc):
            arcpy.management.Delete(out_fc)
        raise
    finally:
        if scur:
            del scur
        if icur:
            del icur
        if irow:
            del irow
        for data in ["in_memory/grouped", temppoly, templine, clip, bisected, dissolve]:
            if data:
                try:
                    arcpy.management.Delete(data)
                except:
                    ""

def MakeBisector(min,max,constant, templatefc, axis):
    if axis == "x":
        array = arcpy.Array()
        array.add(arcpy.Point(min, constant))
        array.add(arcpy.Point(max, constant))
    else:
        array = arcpy.Array()
        array.add(arcpy.Point(constant, min))
        array.add(arcpy.Point(constant, max))
    line = arcpy.Polyline(array, arcpy.Describe(templatefc).spatialReference)
    return line

def GetRounder(in_features):
    try:
        unit = arcpy.Describe(in_features).spatialReference.linearUnitName.lower()
    except:
        unit = "dd"
    if unit.find("foot") > -1:
        rounder = 1
    elif unit.find("kilo") > -1:
        rounder = 3
    elif unit.find("meter") > -1:
        rounder = 1
    elif unit.find("mile") > -1:
        rounder = 3
    elif unit.find("dd") > -1:
        rounder = 5
    else:
        rounder = 3
    return rounder

# Run the script
if __name__ == '__main__':
    # Get Parameters
    in_features = arcpy.GetParameterAsText(0) or r"C:\PolygonBisector\Data\Sample.gdb\Poly"
    out_fc = arcpy.GetParameterAsText(1) or r"C:\PolygonBisector\Data\Sample.gdb\Poly_xbisector2"
    axis = arcpy.GetParameterAsText(2).lower() or "x"
    groupfields = arcpy.GetParameterAsText(3).split(";") if arcpy.GetParameterAsText(3) else []
    error = float(arcpy.GetParameter(4)) if arcpy.GetParameter(4) else 0.001

    # Run the main script
    PolygonBisector(in_features, out_fc, axis, groupfields, error)
    print "finished"
