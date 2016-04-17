#! /usr/bin/env python

from jdcal import gcal2jd
from fitshdr import stream_log_for_files, stream_log_for_catalog
import sys

def formatfilter(original):
    if original == 'Ha wide':
        return 'Haw'
    elif original == 'Ha narrow':
        return 'Han'
    else:
        return '  ' + original

def formatjday(obsdate, ut):
    Y, M, D = (obsdate[6:10], obsdate[3:5], obsdate[0:2])
    h, m, s = (float(ut[0:2]), float(ut[3:5]), float(ut[6:8]))
    jd = sum(gcal2jd(Y, M, D)) + ((s/60 + m)/60 + h)/24
    return "{:15.6f}".format(jd)

# rules for bialkow-calib nightlog format
# (as in mklog-bialkow.awk)
bialkow_rulez = [
    ('FILE', lambda k, h, filename, **args: "{:>22s}".format(filename)),
    ('YYYY', lambda k, h, **args: h['OBS-DATE'][6:10]),
    ('MM', lambda k, h, **args: h['OBS-DATE'][3:5]),
    ('DD', lambda k, h, **args: h['OBS-DATE'][0:2]),
    ('HH', lambda k, h, **args: ' ' + h['UT'][0:2]),
    ('MI', lambda k, h, **args: h['UT'][3:5]),
    ('SS', lambda k, h, **args: h['UT'][6:8]),
    ('EXPOSURE', lambda k, h, **args: '{:6.1f}'.format(h['EXPOSURE'])),
    ('SPEED', lambda k, h, **args: '{:3d}'.format(h['GAIN'])),
    ('FILTER', lambda k, h, **args: formatfilter(h['FILTER'])),
    ('DATA-TYP', lambda k, h, **args: '{:>7s}'.format(h['DATA-TYP'])),
    ('OBJECT', lambda k, h, **args: '{:>12s}'.format(h['OBJECT'])),
    ('JDAY', lambda k, h, **args: formatjday(h['OBS-DATE'], h['UT'])),
]


if __name__ == "__main__":
    import argparse

    ## parse script arguments
    argparser = argparse.ArgumentParser()
    argparser.description = \
        '''Make Bialkow log in the calib-bialkow format,
            reads the list of FITS files from stdin, outputs a log to stdout
            and warnings (sometimes a lot) to stderr'''
    argparser.epilog = 'example:\n\t ls -tr *.fits | pyfits_mk_log.py > night.log 2> error.log'
    argparser.add_argument('-l', '--logfile', help='name of logfile (instead of stdout)')
    argparser.add_argument('-f', '--files', nargs='*', help='files to process e.g.: data/*.fits (instead of stdin)')
    args = argparser.parse_args()

    ostream = sys.stdout if args.logfile is None else open(args.logfile, 'w')
    istream  = sys.stdin  if args.files   is None else args.files

    stream_log_for_files(istream, ostream, bialkow_rulez)

    if args.logfile is not None:
        ostream.close()
