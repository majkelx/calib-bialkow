#! /usr/bin/env python

import sys
from pyraf import iraf

def run_ccdp(input):
    iraf.noao.imred(_doprint=0)
    iraf.noao.imred.ccdred(_doprint=0)
    iraf.ccdproc(input[0],output=input[1],trim="yes",trimsec="[1:1250,1:1150]",zerocor="no",flatcor="yes",flat=input[2],ccdtype="",max_cache="128",noproc="no",fixpix="no",zero="",overscan="no",darkcor="no",illumcor="no",fringecor="no",readcor="no",scancor="no",readaxis="line",fixfile="",biassec="",dark="",illum="",fringe="",minreplace="1.0",scantype="shortscan",nscan="1",interactive="no",function="legendre",order="1",sample="*",naverage="1",niterate="1",low_reject="3",high_reject="3",grow="0.0")

if __name__ == "__main__":
    run_ccdp(sys.argv[1:])
