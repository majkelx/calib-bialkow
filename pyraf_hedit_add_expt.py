#! /usr/bin/env python

import sys
import numpy as np
from pyraf import iraf

def run_hedit_add_expt(input):
	dt=np.dtype({'names':['filename','year','month','day','hours','minutes','seconds','exptime','speed','filter','type','object','jd'],'formats':['S24','S4','S2','S2','S2','S2','S2',np.float,np.int,'S3','S9','S12',np.float]})
	data=np.loadtxt(open(input[0]),dtype=dt)
	for i in np.arange(0,len(data['filename']),1):
                iraf.hedit(data['filename'][i], "EXPTIME", data['exptime'][i], add="yes", addonly="no", verify="no", show="no", update="yes")


if __name__ == "__main__":
    if len(sys.argv) != 2 :
      print ""
      print "Usage:"
      print " ./pyraf_hedit_add_bialkow.py <night_log>"
      exit()

    run_hedit_add_expt(sys.argv[1:])
