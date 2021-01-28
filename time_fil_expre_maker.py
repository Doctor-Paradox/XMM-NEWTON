#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Dec 12 19:45:47 2020

@author: gurpreet
makes timefilter expression in user defined way
(TIME <= 73227600)&&!(TIME in [73221920:73223800])
"""
# from astropy.utils.data import get_pkg_data_filename
from astropy.table import Table
import matplotlib.pyplot as plt
import sys
filename=str(sys.argv[1])
events = Table.read(filename)
x=events['TIME']
y=events['RATE']
xclick=[]
yclick=[]
def onclick(event):
    # print(event.xdata, event.ydata)
    xclick.append(event.xdata)
    yclick.append(event.ydata)
fig,ax = plt.subplots()
ax.plot(x,y)
ax.set_xlabel("TIME")
ax.set_ylabel("RATE")
ax.set_title("Pairs of selected times in chronological order will included in filter...")
# ax.title("points within each click will be reatined in filter")
fig.canvas.mpl_connect('button_press_event', onclick)
plt.show()
filterexpression='(TIME IN '
# print(xclick,yclick)
# xclick=[578313121.8296872, 578316357.9587195, 578318178.2813001, 578320858.200655]
# print(xclick)
for i in range(0,len(xclick)-1,2):
    filterexpression=str(filterexpression)+"["+str(xclick[i])+":"+str(xclick[i+1])+"])||(TIME IN "
print(filterexpression[:-11])