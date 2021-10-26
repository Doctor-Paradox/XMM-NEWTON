#!/usr/bin/env python3

"""
Created on Tue Aug 17 20:16:49 2021

@author: aries
"""
import sys
f=open(sys.argv[1], encoding="utf8", errors='ignore')
# f=open("/home/aries/phd/coronally_connected_detached_binaries/visible_binaries/I_Boo/0100650101/mos/MOS1_1_UFILT_TIME_pileup.txt")
lines=f.readlines()
splitted=[]
for line in lines:
    splitted.append(line.split())
print(splitted[0][-4])
