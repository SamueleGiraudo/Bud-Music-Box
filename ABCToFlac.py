#!/usr/bin/env python

# Author: Samuele Giraudo
# Creation: aug. 2109
# Modifications: aug. 2019, nov. 2023, dec. 2023

import sys
import os

path_fonts = "/usr/share/soundfonts/FluidR3_GM.sf2"

help_text ="Usage: ./ABCToFlac FILE.abc. Convert FILE.abc into FILE.flac.\n"

if len(sys.argv) != 2 :
    print("Error: wrong argument number.")
    print(help_text)
    exit(1)

file_name = sys.argv[1]
prefix = file_name[:-3]

if len(file_name) <= 4 or file_name[-4:] != ".abc" :
    print("Error: wrong file extension.")
    print(help_text)
    exit(1)

os.system("abcm2ps \"%sabc\" -O \"%sps\"" %(prefix, prefix))
os.system("ps2pdf \"%sps\"" %(prefix))
os.system("rm \"%sps\"" %(prefix))
os.system("abc2midi \"%s\" -o \"%smid\"" %(file_name, prefix))
os.system("fluidsynth -F \"%sflac\" -T flac -O s24 \"%s\" \"%s\""\
    %(prefix, path_fonts, file_name))

exit(0)

