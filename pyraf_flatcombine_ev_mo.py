#! /usr/bin/env python

import sys
from pyraf import iraf

def run_flatcom(input):
    iraf.noao.imred()
    iraf.noao.imred.ccdred()
    iraf.flatcombine(input[0],output=input[1],combine="average",scale="mean",reject="none",nlow="0",nhigh="0",nkeep="1",ccdtype="",process="no",subsets="no",delete="no",clobber="no",statsec="[100:1000,100:1000]",mclip="no",lsigma="3",hsigma="3",rdnoise="6",gain="7",snoise="0",pclip="-0.5",blank="1.0")

if __name__ == "__main__":
    run_flatcom(sys.argv[1:])
