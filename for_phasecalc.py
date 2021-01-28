#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan  6 21:20:42 2021

@author: aries
It gives names of exposures used for phasecalc in sas (phase resolved spectroscopy)
"""
from astropy.io import fits
import re
import sys
filename=str(sys.argv[1])
hdu_list = fits.open(filename, memmap=True)
ff=hdu_list.info("")
sa=re.findall('EXPOS[a-zA-Z][0-9]+',str(ff))
for s in sa:
    print(s)
