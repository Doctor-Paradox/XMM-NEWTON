#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug 29 19:54:33 2021

@author: aries
"""
import os
import sys
import astropy.io.fits as fits
import numpy as np

filename=sys.argv[1]
f=fits.open(filename)
s=np.array(f[1].data)
filterexpression='(TIME IN '
for i in range(len(s)):
    filterexpression=str(filterexpression)+"["+str(s[i][0])+":"+str(s[i][1])+"])||(TIME IN "
print(filterexpression[:-11])
