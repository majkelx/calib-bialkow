#! /usr/bin/env python

import sys
from pyraf import iraf

def run_ccdp(input):
    iraf.noao.imred()
    iraf.noao.imred.ccdred()
    iraf.ccdproc(input[0],output=input[1],trim="no",trimsec="",zerocor="no",flatcor="no",flat="",ccdtype="",max_cache="128",noproc="no",fixpix="no",zero="",overscan="no",darkcor="yes",illumcor="no",fringecor="no",readcor="no",scancor="no",readaxis="line",fixfile="",biassec="",dark=input[2],illum="",fringe="",minreplace="1.0",scantype="shortscan",nscan="1",interactive="no",function="legendre",order="1",sample="*",naverage="1",niterate="1",low_reject="3",high_reject="3",grow="0.0")

if __name__ == "__main__":
    run_ccdp(sys.argv[1:])
