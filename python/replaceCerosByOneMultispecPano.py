import fileinput, sys, os

#Replace text in file
def replaceInFile(file,searchText,replaceText):
    for line in fileinput.input(file, inplace=True):
        line = line.replace(searchText, replaceText)
        # sys.stdout is redirected to the file
        sys.stdout.write(line)
#Copy the file        
def copyFile(inputFile, copy):
    #Copy the file
    with open(inputFile) as f:
        with open(copy, "w") as f1:
            for line in f:
                    f1.write(line)

################ INPUTS ######################        
##############################################
date="160204"
file = "m160204bw8-0.pano"  # make if finish in "-0.pano"

folder=os.path.normpath(r"G:/AD15_16/"+date+"/m/pno/")
##############################################
fileToSearch=os.path.join(folder,file)
textToSearch="-0.tif"
textToReplace="-1.tif"
copiedfile=fileToSearch.replace("-0.pano", "-1.pano")

print ("start")
#Copy the file
copyFile(fileToSearch, copiedfile)
#Replace                
replaceInFile(copiedfile,textToSearch,textToReplace)
