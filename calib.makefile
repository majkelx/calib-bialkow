### User targets:

#declare no-file user targets (pony targets)
#.PHONY: default calib force-calib log force-log flat force-flat clean-all clean-for-calib clean-log

default: calib

calib: CALIB_FILES/calibration_processed

force-calib: clean-for-calib calib

log: night.log

force-log: clean-log log

flat: CALIB_FILES/flats_processed

force-flat: clean-for-calib flat

clean-all: clean-for-calib clean-log

clean-for-calib:
	cb_clear.bash

clean-log:
	rm night.log

### File targets:

night.log:
	ls -tr $(FITS_PATH)/*-????.fits | pyfits_mk_log.py -s -l night.log 2>/dev/null
	cp night.log night.original.log

CALIB_FILES/flats_processed: night.log
	cb_clear.bash
	calib_bialkow_new.bash night.log f

CALIB_FILES/calibration_processed: CALIB_FILES/flats_processed
	calib_bialkow_new.bash night.log o

### Experimental targets:

setinstrument:mkiraf
	pyraf_setinstrument.py

mkiraf: login.cl

login.cl:
	cp ~/login.cl .

./CALIB_FILES/ff-ev-flat.sts:
	echo "dupa"

#CALIB_FILES/: night.log
#	cb_clear.bash
#	calib_bialkow_new.bash night.log
