#! /usr/bin/env python

import sys
from pyraf import iraf

def run_ccdp(input):
    iraf.image(_doprint=0)
    iraf.image.imutil(_doprint=0)
    iraf.imarith(input[0],"-",input[1],input[2],divzero="0.0",hparams="",pixtype="",calctype="",verbose="no",noact="no")

if __name__ == "__main__":
    run_ccdp(sys.argv[1:])
