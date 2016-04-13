#!/usr/bin/python
import sys
import numpy as np

if len(sys.argv) !=  3:
  print " "
  print "Program returns linear interpolation for average BIAS"
  print "Usage:"
  print "  ./bias_interp.py <file with BIAS measurements> <file with obs. sampling>\n"
  print "  first file format: filename, time [d], mean_bias [ADU]"
  print "  second file format: filename, time [d], exp_time [s]"
  print " ZK, ver. 2013.11.11"
  print " "
  exit()

bias_sample = sys.argv[1]
obs_time = sys.argv[2]
f1 = open(bias_sample, 'r')
f2 = open(obs_time, 'r')
tb, b = np.loadtxt(f1, usecols=(1, 2), unpack=True)

fname, tob, expt = np.loadtxt(f2,dtype={'names': ('filename', 'time', 'exp_time'),'formats': ('S25', 'f', 'i4')},unpack=True)
tob=tob+(expt/(2.0*86400.0))
bi = np.interp(tob, tb, b)
for l in  range(len(fname)):
  print "%-25s %8.6f %7.2f" % (fname[l],tob[l],bi[l])

