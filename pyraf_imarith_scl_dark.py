#! /usr/bin/env python

import sys
from pyraf import iraf

def run_scldark(input):
    iraf.image(_doprint=0)
    iraf.image.imutil(_doprint=0)
    scl=float(input[1])/float(input[2])
#    print input[1],scl
    iraf.imarith(input[0],"*",scl,input[3],divzero="0.0",hparams="",pixtype="",calctype="",verbose="no",noact="no")
    iraf.hedit(input[3],"EXPTIME",input[1], add="yes", addonly="yes", delete="no", verify="no", show="no", update="yes")
    iraf.hedit(input[3],"DARKTIME",input[1], add="yes", addonly="yes", delete="no", verify="no", show="no", update="yes")
    iraf.hedit(input[3],"EXPOSURE","", add="no", addonly="no", delete="yes", verify="no", show="no", update="yes")

if __name__ == "__main__":
    run_scldark(sys.argv[1:])

