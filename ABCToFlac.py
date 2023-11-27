#!/usr/bin/env python

# Author: Samuele Giraudo
# Creation: aug. 2109
# Modifications: aug. 2019, nov. 2023

import sys
import os

path_fonts = "/usr/share/soundfonts/FluidR3_GM.sf2"

help_text =\
"Usage:\n\
    FILE.abc: convert into FILE.flac\n"

if len(sys.argv) != 2 :
    print("Error: wrong argument number.")
    print(help_text)
    exit(1)

file_name = sys.argv[1]

if len(file_name) <= 4 or file_name[-4:] != ".abc" :
    print("Error: wrong file extension.")
    print(help_text)
    exit(1)

#os.system("abcm2ps " + file_name[:-3] + "abc  -O " + file_name[:-3] + "ps");
#os.system("ps2pdf " + file_name[:-3] + "ps")
#os.system("rm " + file_name[:-3] + "ps")
os.system("abc2midi " + file_name + " -o " + file_name[:-3] + "mid");
#os.system("fluidsynth -F " + file_name[:-3]\
 #   + "wav /usr/share/soundfonts/FluidR3_GM.sf2 " + file_name[:-3] + "mid")

os.system("fluidsynth -F %swav %s %smid" %(file_name[:-3], path_fonts, file_name[:-3]))

os.system("flac -f " + file_name[:-3] + "wav")
os.system("rm " + file_name[:-3] + "wav")

exit(0)

