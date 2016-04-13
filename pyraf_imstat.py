#! /usr/bin/env python

import sys
from pyraf import iraf

def run_imstat(input):
    iraf.images()
    for image in input:
        iraf.imstat(image,fields="image,npix,mean,stddev,min,max",lower="INDEF",upper="INDEF",nclip="0",lsigma="3",usigma="3",binwidth="0.1",format="no",cache="no")

if __name__ == "__main__":
    run_imstat(sys.argv[1:])
