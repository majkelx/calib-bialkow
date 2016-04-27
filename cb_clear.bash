rm *.cat *.h *.sts *flat*.fits *-bt.fits ff*.log *div*.fits *-b.fits *-btf.fits *-dark.fits *-bias.fits
rm dark*expt* *-bd.fits *bdtf.fits obj* night-bias*
rm -r pyraf
rm flats_processed
rm -r CALIB_DATA.PREV
rm -r CALIB_FILES.PREV
mv CALIB_DATA CALIB_DATA.PREV
mv CALIB_FILES CALIB_FILES.PREV
exit 0