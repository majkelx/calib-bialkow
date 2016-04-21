#! /usr/bin/env python

import sys
import f2n
from PIL import ImageOps as imop
from PIL import Image as im
import numpy as np


## corrected version of f2n.makepilimage (only lin scale - sorry)
def makepilimage(self, negative = False):
    """
    Makes a PIL image out of the array, respecting the z1 and z2 cutoffs.
    By default we use a log scaling identical to iraf's, and produce an image of mode "L", i.e. grayscale.
    But some drawings or colourscales will change the mode to "RGB" later, if you choose your own colours.
    If you choose scale = "clog" or "clin", you get hue values (aka rainbow colours).
    """

    calcarray = self.numpyarray.transpose()

    self.negative = negative
    #numpyarrayshape = self.numpyarray.shape

    #calcarray.ravel() # does not change in place in fact !
    calcarray = calcarray.clip(min = self.z1, max = self.z2)

    def lingray(x, a=None, b=None):
        if a == None:
            a = np.min(x)
        if b == None:
            b = np.max(x)
        return 255.0 * (x - float(a)) / (b - a)

    calcarray = lingray(calcarray, self.z1, self.z2)
    bwarray = np.array(calcarray.round(), dtype=np.uint8)

    if negative:
        if self.verbose:
            print "Using negative scale"
        bwarray = 255 - bwarray

    if self.verbose:
        print "PIL range : [%i, %i]" % (np.min(bwarray), np.max(bwarray))

    # We flip it so that (0, 0) is back in the bottom left corner as in ds9
    # We do this here, so that you can write on the image from left to right :-)

    self.pilimage = imop.flip(im.fromarray(bwarray))
    if self.verbose:
            print "PIL image made with scale : lin"
    return 0



def run_fits2png(input):
           image = f2n.fromfits(input[0]) #colour=( The way to read a FITS file.
           image.setzscale() # By default, automatic cutoffs will be calculated.
           makepilimage(image) # linear scale
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

