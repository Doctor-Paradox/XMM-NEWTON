#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug 29 19:54:33 2021

@author: aries
create time filter expressions for flaring regions from quiet lightcurve...
use:
code quiet.lc 
output:
array of timefilter expressions...
"""
import os
import sys
import astropy.io.fits as fits
import numpy as np

filename=sys.argv[1]
f=fits.open(filename)
s=np.array(f[1].data)
filterexpression='(TIME IN '
n=1
#print(s)
# s is gonna be a matrix of size nX2
for i in range(len(s)-1):    #this len is n
    #filterexpression='(TIME IN '+"["+str(s[i][1])+":"+str(s[i+1][0])+"])"
    filterexpression="["+str(s[i][1])+":"+str(s[i+1][0])+"]"
    print(str(filterexpression))
    n+=1
#print(filterexpression[:-11])
