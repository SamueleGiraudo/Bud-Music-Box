#!/usr/bin/env python

# Author: Samuele Giraudo
# Creation: dec. 2023
# Modifications: dec. 2023

import sys
import os

path_fonts = "/usr/share/soundfonts/FluidR3_GM.sf2"

help_text ="Usage: ./MidToFlac FILE.mid. Convert FILE.mid into FILE.flac.\n"

if len(sys.argv) != 2 :
    print("Error: wrong argument number.")
    print(help_text)
    exit(1)

file_name = sys.argv[1]
prefix = file_name[:-3]

if len(file_name) <= 4 or file_name[-4:] != ".mid" :
    print("Error: wrong file extension.")
    print(help_text)
    exit(1)

os.system("fluidsynth -F \"%sflac\" -T flac -O s24 \"%s\" \"%s\""\
    %(prefix, path_fonts, file_name))

exit(0)

