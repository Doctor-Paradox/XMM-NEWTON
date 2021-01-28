#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 24 14:51:30 2020

@author: gurpreet
"""

words=[]
with open("coord.txt",'r') as file: 
    for line in file: 
        for word in line.split(): 
            words.append(word)
for l in range (len(words)):
    if (words[l] == 'X:'):
        print("X=",words[l+2])
        print("Y=",words[l+3])