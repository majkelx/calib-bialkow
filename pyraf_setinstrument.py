#! /usr/bin/env python

from pyraf import iraf

def run_setinstrument():
#    iraf
    iraf.noao.imred(_doprint=0)
    iraf.noao.imred.ccdred(_doprint=0)
    iraf.setinstrument('camera', review='no')


if __name__ == "__main__":
    run_setinstrument()
