#! /usr/bin/env python

import sys
from pyraf import iraf

def run_zerocom(input):
    iraf.noao.imred()
    iraf.noao.imred.ccdred()
    iraf.zerocombine(input[0],output=input[1],combine="average",reject="minmax",ccdtype="",process="no",delete="no",clobber="no",scale="none",statsec="[100:1000,100:1000]",nlow="1",nhigh="1",nkeep="3",mclip="no",lsigma="3",hsigma="3",rdnoise="6",gain="7",snoise="0")

if __name__ == "__main__":
    run_zerocom(sys.argv[1:])
