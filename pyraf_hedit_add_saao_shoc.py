#! /usr/bin/env python

import sys
import numpy as np
from pyraf import iraf

def run_hedit_add_saao_shoc(input):
	new_h={'CTYPE1': 'RA---TAN', 'CTYPE2': 'DEC--TAN','RADESYS': 'FK5     ', 'EQUINOX': '2000.0', 'CRPIX1': 625, 'CRPIX2': 575, 'CUNIT1': 'deg     ', 'CUNIT2': 'deg     ', 'CDELT1': 0.0001702, 'CDELT2': 0.0001702, 'EPOCH': 2000.0, 'TIMESYS': 'UTC     ', 'OBSERVAT': 'SAAO', 'LATITIDE': -32.37944, 'LONGITUD': 339.1893, 'ALTITUDE': 1800, 'INSTRUME':'SHOC', 'OBSERVER':'E.Zahajkiewicz'}
	dt=np.dtype({'names':['filename','year','month','day','hours','minutes','seconds','exptime','filter','object','ra','dec'],'formats':['S40','S4','S2','S2','S2','S2','S2',np.float,'S1','S10','S9','S10']})
	data=np.loadtxt(open(input[0]),dtype=dt)
#        print data['year'][0]
	for i in np.arange(0,len(data['filename']),1):
		date_obs=data['year'][i]+"-"+data['month'][i]+"-"+data['day'][i]+"T"+data['hours'][i]+":"+data['minutes'][i]+":"+data['seconds'][i]
                iraf.hedit(data['filename'][i], "DATE-OBS", date_obs, add="yes", addonly="no", verify="no", show="no", update="yes")
		for key in new_h:
			iraf.hedit(data['filename'][i], key, new_h[key], add="yes", addonly="no", verify="no", show="no", update="yes")

		str=data['ra'][i]
		ra_tab=str.split(':',2)
		ra_deg=(int(ra_tab[0])+int(ra_tab[1])/60.0+int(ra_tab[2])/3600.0)*15.0
                ra_h=int(ra_tab[0])/1.0+int(ra_tab[1])/60.0+int(ra_tab[2])/3600.0
                str=data['dec'][i]
		dec_tab=str.split(':',2)
		if(int(dec_tab[0]) >= 0):
			dec_deg=(int(dec_tab[0])+int(dec_tab[1])/60.0+int(dec_tab[2])/3600.0)
		else:
			dec_deg=(int(dec_tab[0])-int(dec_tab[1])/60.0-int(dec_tab[2])/3600.0)

                iraf.hedit(data['filename'][i], "CRVAL1", ra_deg, add="yes", addonly="no", verify="no", show="no", update="yes")
		iraf.hedit(data['filename'][i], "CRVAL2", dec_deg, add="yes", addonly="no", verify="no", show="no", update="yes")
		iraf.hedit(data['filename'][i], "RA", ra_h, add="yes", addonly="no", verify="no", show="no", update="yes")
		iraf.hedit(data['filename'][i], "DEC", dec_deg, add="yes", addonly="no", verify="no", show="no", update="yes")
#		iraf.hedit(data['filename'][i], "LMST", data['lmst'][i] , add="yes", addonly="no", verify="no", show="no", update="yes")
#               iraf.hedit(data['filename'][i], "HA",data['ha'][i], add="yes", addonly="no", verify="no", show="no", update="yes")
#               iraf.hedit(data['filename'][i], "ALT",data['alt'][i], add="yes", addonly="no", verify="no", show="no", update="yes")
#		iraf.hedit(data['filename'][i], "AIRMASS",data['airm'][i], add="yes", addonly="no", verify="no", show="no", update="yes")

if __name__ == "__main__":
    if len(sys.argv) < 2:
      print ""
      print "Usage:"
      print " ./pyraf_hedit_add_saao_shoc.py <obs_log>"
      exit()

    run_hedit_add_saao_shoc(sys.argv[1:])
