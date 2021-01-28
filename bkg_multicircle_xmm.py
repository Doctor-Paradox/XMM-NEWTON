#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec  8 15:17:20 2020

@author: aries
multibackground regions for xmm epic deflaring
(((X,Y) IN circle(23802.3,25148.4,241.61)||(X,Y) IN circle(24134.4,24658.9,184.069)||(X,Y) IN circle(24449.1,24204.4,173.959)||(X,Y) IN circle(24903.6,25130.9,277.871)||(X,Y) IN circle(25026,24396.6,217.835)||(X,Y) IN circle(25043.5,23924.6,114.506)))
"""
#(FLAG==0)&&(PATTERN<=4)&&(((X,Y) IN circle(26883.5,24752,1091.09)||(X,Y) IN circle(28536.5,26753,1336.59)))
#(FLAG==0)&&(PATTERN<=4)&&(((X,Y) IN circle(27050.5,25750.5,1510.1286)))
import re
import sys
name=str(sys.argv[1])
whichdetector=str(sys.argv[2])
flarecheck=str(sys.argv[3])
f=open(name)
lines=f.readlines()
e=''
if(whichdetector == 'pn' and flarecheck == 'yes'):
    expre='(PI>10000&&PI<12000)&&(PATTERN==0)&&#XMMEA_EP&&'
elif(whichdetector == 'mos' and flarecheck == 'yes'):
    expre='#XMMEA_EM&&(PI>10000)&&(PATTERN==0)&&'
elif(whichdetector == 'pn' and flarecheck == 'no'):
    expre="(FLAG==0)&&(PATTERN<=4)&&#XMMEA_EP&&"
else:
    expre="#XMMEA_EM&&(PATTERN<=12)&&"
for line in lines:
    if (re.search('circle',line)):
#        print(str(line))
#        expre=str(expre)+str(line)
        e=str(e)+str(line)
#print(expre)
#ex=expre.split()
ex=e.split()
final=''
for i in range(len(ex)):
    final=final+ex[i]+'||(X,Y) IN '
han="(((X,Y) IN "+final[:-11]+"))"
print(str(expre)+str(han))