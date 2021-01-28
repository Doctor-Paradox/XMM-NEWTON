#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 27 12:21:14 2020

@author: gurpreet
"""

import numpy as np
words=[]
with open("srcmatchi.txt",'r') as file: 
    for line in file:
        for word in line.split(): 
            words.append(word)
            # displaying the words            
#            print(word)  
for l in range (len(words)):
    if (words[l] == 'physical'):
        intere = words[l+1]
intere = str(intere)
bad_char= [ 'c' , 'i' , 'r' , 'l' , 'e' , '(' , ')']
for ina in bad_char:
    intere = intere.replace(ina,' ')  
#print(intere)
splits = intere.split(",")
#print (splits)
xcord= float(splits[0])
ycord= float(splits[1])
areaPix= float(splits[2])
print(xcord,ycord,areaPix)