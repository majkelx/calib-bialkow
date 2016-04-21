#! /usr/bin/env python

from pyraf import iraf

def run_setinstrument():
#    iraf
    iraf.noao.imred()
    iraf.noao.imred.ccdred()
    iraf.setinstrument('camera', review='no')


if __name__ == "__main__":
    run_setinstrument()
