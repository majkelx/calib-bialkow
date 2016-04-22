#! /usr/bin/env python
"""
Lists fits header cards.
"""
import pyfits

if __name__ == "__main__":
    import argparse

    # parse script arguments
    argparser = argparse.ArgumentParser()
    argparser.description = 'List  FITS headers'
    argparser.add_argument('files', nargs='+', help='files to process')
    args = argparser.parse_args()

    for f in args.files:
        f = f.strip()
        huds = pyfits.open(f)
#        if autofix:
#            huds[0].verify('silentfix')
        srchdr = huds[0].header
        huds.close()
        print repr(srchdr)

