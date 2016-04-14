#!/usr/bin/env bash

if [ $# -lt 1 ]
then
#clear
echo ""
echo " Script mk_log_wcss.bash"
echo " makes new log file for" 
echo " ANDOR CCD images from Bialkow observatoty"
echo ""
echo " Usage: mk_log_wcss.bash <directory>"
echo ""
echo " "
echo " Script reads headers of all FITS files"
echo " in the selected directory."
echo " The result is log file with name <directory>.log"
echo " located in <directory>." 
echo " Version: 2015.10.14, (ZK)"
echo " Calib_PATH: ${Calib_PATH}"
echo ""
exit
fi

##################
## SET VARIABLES:
export LANG=C

wdir="$1"
logfile="${wdir}.log"

edit="gvim -f"

###

if test ! -s ${Calib_PATH}/mk_log_wcss.bash
then
echo " Script mk_log_wcss.bash does not exist in ${Calib_PATH} directory !"
exit
fi

if test ! -d ${wdir}
then
echo " ${wdir}: no such directory"
exit
fi

cd ${wdir}

nlog=`ls *.log |wc -l`

if test ${nlog} -gt 1
then
ls *.log
echo ""
echo " Too many log files in the ${wdir} directory."
echo " The one file is expected here, original log made in observatory."
echo " Remove other files and run the script again."
echo ""
exit
fi

if test ${nlog} -gt 1
then
echo " Warning: there is no log file in the ${wdir}  directory"
fi

awk 'NR>5 &&  $1 !~ /\.fits/' *.log > comments.txt
rm *.log
cat comments.txt

if test ! -s ${logfile}
then
for i in `ls -tr *.fits` ; do mk_log_wcss.awk $i ; done > ${logfile}
else
rm -f ${logfile}

for i in `ls -tr *.fits` ; do mk_log_wcss.awk $i ; done > ${logfile}
fi

echo "#    OBSERVATORY: Bialkow  TELESCOPE: Cassegrain_60  INSTRUMENT: CCD_ANDOR_DW432_BV" > tmp_log
echo "#        FILE             DATE        UT      EXPT  G  FILT DATA-TYP   OBJECT         JD       CCDTEMP  OBSERVER" >> tmp_log

# sorting logfile in the chronological order:
sort -n -k 13 ${logfile} >> tmp_log

mv tmp_log ${logfile}

echo "" >> ${logfile}
cat comments.txt >> ${logfile}
rm comments.txt

echo " Log-file  ${logfile}  done."

pwd
ls -l ${logfile}
cd ~-

#${edit} ${logfile}


