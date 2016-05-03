#! /usr/bin/env python

import sys
from pyraf import iraf

def run_flatcom(input):
    iraf.noao.imred(_doprint=0)
    iraf.noao.imred.ccdred(_doprint=0)
    iraf.flatcombine(input[0],output=input[1],combine="median",scale="mode",reject="avsigclip",nlow="0",nhigh="0",nkeep="3",ccdtype="",process="no",subsets="no",delete="no",clobber="no",statsec="[300:800,300:800]",mclip="yes",lsigma="2.7",hsigma="2.7",rdnoise="6.0",gain="7.0")

if __name__ == "__main__":
    run_flatcom(sys.argv[1:])
