#! /usr/bin/env python

import sys
from pyraf import iraf

def run_ccdp(input):
    iraf.noao.imred()
    iraf.noao.imred.ccdred()
    iraf.ccdproc(input[0],output=input[1],zerocor="no",trim="yes",trimsec="[1:1250,1:1150]",zero="",ccdtype="",max_cache="256",noproc="no",fixpix="no",overscan="no",darkcor="no",flatcor="no",illumcor="no",fringecor="no",readcor="no",scancor="no",readaxis="line",fixfile="",biassec="",flat="",dark="",illum="",fringe="",minreplace="1.0",scantype="shortscan",nscan="1",interactive="no",function="legendre",order="1",sample="*",naverage="1",niterate="1",low_reject="3",high_reject="3",grow="0.0")
    iraf.ccdproc(input[1],output=input[2],zerocor="yes",trim="no",trimsec="",zero=input[3],ccdtype="",max_cache="256",noproc="no",fixpix="no",overscan="no",darkcor="no",flatcor="no",illumcor="no",fringecor="no",readcor="no",scancor="no",readaxis="line",fixfile="",biassec="",flat="",dark="",illum="",fringe="",minreplace="1.0",scantype="shortscan",nscan="1",interactive="no",function="legendre",order="1",sample="*",naverage="1",niterate="1",low_reject="3",high_reject="3",grow="0.0")

if __name__ == "__main__":
    run_ccdp(sys.argv[1:])
