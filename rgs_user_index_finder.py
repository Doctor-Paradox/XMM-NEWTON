#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov 28 12:02:07 2020

@author: gurpreet
"""
from astropy.io import fits
# srclist=Table.read("R1_SRCLI.FITS",hdu=1)
import sys
srclist=fits.open(str(sys.argv[1]))
date=srclist[1].data
new=date.view()
i = 0
while True:
   if (new[i][1] == "USER"):
       f=1
       print(new[i][0])
       break
   else:
       i = i + 1
if (f != 1):
    print("NOT")