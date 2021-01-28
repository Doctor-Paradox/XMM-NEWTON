#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 27 13:34:04 2020

@author: gurpreet
"""
#rgs pileup checker
from astropy.utils.data import get_pkg_data_filename
from astropy.table import Table
from astropy.io import fits
import matplotlib.pyplot as plt
import glob
import numpy as np
import sys
def plotter(qq,rr):
    o1=glob.glob(str(qq))
    o2=glob.glob(str(rr))
    # o1="/home/gurpreet/Downloads/0785140501/rgs/P0785140501OBX000fluxed1000.FIT"
    # o2="/home/gurpreet/Downloads/0785140501/rgs/P0785140501OBX000fluxed1000.FIT"
    # events = Table.read(o1)
    events = Table.read(str(o1[0]))
    channel1=events['CHANNEL']
    counts1=events['FLUX']
    error1=events['ERROR']
    # events2 = Table.read(o2)
    
    events2 = Table.read(str(o2[0]))
    channel2=events2['CHANNEL']
    counts2=events2['FLUX']
    error2=events2['ERROR']
    print("first order spectra file is:",o1[0],"\n second order file is:",o2[0])
    # plt.scatter(channel1,counts1/counts2)
    x=[]
    y=[]
    e=[]
    y1=[]
    y2=[]
    e1=[]
    e2=[]
    for i in range(len(channel1)):
        if(channel1[i]> 6. and channel1[i] < 20.0):
            
            if (counts1[i] > 0 and counts2[i] > 0 ):
                # if (counts1[i]/counts2[i] < 2.0):
                # if(abs(counts2[i]/counts1[i])*np.sqrt((error1[i]/counts1[i])**2 + (error2[i]/counts2[i])**2) < 10.):
                x.append(channel1[i])
                ytemp=counts1[i]/counts2[i]
                y.append(ytemp)
                y1.append(counts1[i])
                y2.append(counts2[i])
                e1.append(error1[i])
                e2.append(error2[i])
                e.append(abs(ytemp)*np.sqrt((error1[i]/counts1[i])**2 + (error2[i]/counts2[i])**2))
        else:
            # print("value is less than")
            continue
    
    plt.subplot(2,1,1)
    # plt.plot(x,y1,x,y2)
    plt.errorbar(x,y1,e1,color='blue')
    plt.errorbar(x,y2,e2,color='orange')
    plt.subplot(2,1,2)
    # plt.scatter(x,y)
    plt.ylim(0,5)
    plt.errorbar(x,y,e)
    
    plt.xlabel("Wavelength")
    
    plt.show()
    # print("wavelength    ratio(1st/2nd)    error    flux(1st)    error(1st)    flux(2nd)    error(2nd)")
    # for i in range(len(x)):
        # print(x[i],"    ",y[i],"    ",e[i],"    ",y1[i],"    ",e1[i],"    ",y2[i],"   ",e2[i])
    
    print("mean counts are:",np.mean(y))


#plotter("R1_flux_1*","R1_flux_2*")
#plotter("R2_flux_1*","R2_flux_2*")
#plotter("R12_flux_1*","R12_flux_2*")
file1=str(sys.argv[1])
file2=str(sys.argv[2])
plotter(file1,file2)


