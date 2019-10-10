@echo off
cls
rem Save this file in the "SendTo" windows folder and it will appear as an option when you right clik on a file or files...
rem    ...in the windows explorer. It will appear in the "Send to" options and when these files are sent to this command they can be...
rem    ...used as inputs in any script that you call here. This uses the asterix to admit multiple files.
rem    ...this example script that is called is used to replace the 0 by 1 in a file used in the image processing.
python C:\Dropbox\Software\Scripts\python\autopanoFile_replace-0By-1frames.py %*
