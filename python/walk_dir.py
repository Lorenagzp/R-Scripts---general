import os
import sys

drive ='C:'
walk_dir = os.path.join(drive, '\Dropbox','AFebee')

print('walk_dir = ' + walk_dir)

for root, dirs, files in os.walk(walk_dir):
    if root.count(os.path.sep)==4:
        
        if 'img' not in root and 'files' not in root:

            if os.path.isdir(os.path.join(root, '1_initial')):
                if os.path.isdir(os.path.join(root, '2_densification')):
                    if os.path.isdir(os.path.join(root, '3_dsm_ortho')):
                        print root +("\tSTEPS DONE: 3")
                        print 
                else:
                    print root +("\tSTEPS DONE: 1")
            else: print root +("\tSTEPS DONE: NONE")
