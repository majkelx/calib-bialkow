#! /usr/bin/env python
"""
Canonizes fits header cards.
Used at the end of calibration to fine-tune resulting files headers.
In this version:
 - autofix format of cards
 - removes SPACEs form OBJECT card if present.
 - add exptime
Wrongly formated cards are also fixed e.g. string value without quotes
"""
from fitshdr import update_hdr_for_files
import sys


# List of rules for bialkow-calib header canonization
# here is the place to add more rules for FITS standardization (DATE-OBS e.g.)

bialkow_canonize_rulez = [
    ('OBJECT', lambda k, h, **opts: h['OBJECT'].replace(' ', '')),
    ('EXPTIME', lambda k, h, **opts: h.get('EXPOSURE') if 'EXPTIME' not in h else None),
]
# Every rule is a tuple (key_string, value_function)
# result of  value_function will be assigned to the header card identified by key, new or overwriting
# if value_function return None, no change will be made
# if value_function return tuple (value, comment), these will be value and comment of card
# value_function takes arguments:
#   k: key_string same as in rule
#   h: pyfits.Header object to get access to another header fields
#   **opts: any other arguments, passed to fitshdr module routines (eg. update_hdr_for_files)
#       file specified routines adds filename= argument to **opts

if __name__ == "__main__":
    import argparse

    # parse script arguments
    argparser = argparse.ArgumentParser()
    argparser.description = \
        '''Fine-tune Bialkow FITS headers (currenly removes SPACE from OBJECT
            and adds EXPTIME if missing),
            reads the list of FITS files from stdin.
            Wrongly formated cards are also fixed e.g. string value without quotes.'''
    argparser.epilog = 'example:\n\t ls -tr *.fits | pyfits_canonize_hdr.py'
    argparser.add_argument('-f', '--files', nargs='*', help='files to process e.g.: data/*.fits (instead of stdin)')
    args = argparser.parse_args()

    istream = sys.stdin if args.files is None else args.files

    update_hdr_for_files(istream, bialkow_canonize_rulez, autofix=True)
