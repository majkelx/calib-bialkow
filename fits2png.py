#! /usr/bin/env python

import sys
import f2n

def run_fits2png(input):
           image = f2n.fromfits(input[0]) #colour=( The way to read a FITS file.
           image.setzscale() # By default, automatic cutoffs will be calculated.
           image.makepilimage("lin") # linear scale
#	   image.writetitle(input[0], colour=(0,50,250)) 
           image.tonet(input[1]) #  write the png file

if __name__ == "__main__":
	if len(sys.argv) != 3 :
		print "FITS to PNG conversion tool"
		print "based on f2n module"
		print "Usage:"
		print " ./fits2png.py <input FITS_image> <output PNG_image>\n"
		exit()

        run_fits2png(sys.argv[1:])

