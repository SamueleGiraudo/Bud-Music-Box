#!/bin/bash

# Author: Samuele Giraudo
# Creation: nov. 2023
# Modifications: nov. 2023

if [ -d "$1" ]; then
    find "$1" -type f \( -name "*.abc" -o -name "*.ps" -o -name "*.mid" \) -exec rm -f {} +
fi

