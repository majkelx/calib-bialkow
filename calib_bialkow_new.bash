#!/usr/bin/env bash

if [ $# -lt 1 ]
then
#clear
echo ""
echo " Script calib_bialkow_new.bash"
echo " the calibration pipeline for ANDOR CCD images from Bialkow Observatory"
echo " version NOT using dfits (eclipse(ESO)) & jday "
echo ""
echo " Usage: calib_bialkow_new.bash <log file> [l]"
echo " requirements: python 2.6+ with[PyRAF, PyFITS, argparse], gawk, bash4.0+"
echo " and all scripts included in directory ${Calib_PATH}"
echo ""
echo " Log file should be created by mklog-bialkow.awk script !"
echo " Option [l] makes new log file by reading headers of all"
echo " FITS files in the current directory (with .fits extension)."
echo " Version: 2016.04.16, (ZK)"
echo " Calib_PATH: ${Calib_PATH}"
echo ""
exit
fi

##################
## SET VARIABLES:
export LANG=C

logfile="$1"
flat_max_v=30000                
flat_min_v=7000                 
filter_seq="U B V R I Haw Han"  

AUX_FILES_DIR="${Calib_PATH}/AUX_FILES"
CALIB_FILES_DIR="CALIB_FILES"
CDATA_DIR="CALIB_DATA"

long_dark_2="Dark_600_T-50_G2.fits"
long_dark_2_exp="600.0"

long_dark_16="Dark_3000_T-50_G16.fits"
long_dark_16_exp="3000.0"

min_good_flats=5
lim_dark_time="10.0"
min_fits_files=5

edit="gvim -f"

###

if test -d pyraf
    then
    rm -rf pyraf
fi

if test -n "${Calib_PATH}"
    then
    if test -s ${Calib_PATH}/calib_bialkow.bash
        then
        correct_path=`echo ${PATH} | grep -o  "${Calib_PATH}" | awk 'NR==1 {print $1}'`
        if test "${correct_path}" != "${Calib_PATH}"
            then
            echo " PATH: ${PATH}"
            echo " Calib_PATH: ${Calib_PATH}"
            #echo " correct_path: ${correct_path}"
            echo ""
            echo " The PATH variable does not contain path to calibration software."
            echo " Find the directory with calibration software in your system."
            echo " Next find .calib_phot_bialkow_rc file,"
            echo " correct it, if necessary, and type in terminal:"
            echo " source <path_to_file>/.calib_phot_bialkow_rc"
            echo ""
            exit
            fi
    else
        echo " Calib_PATH: ${Calib_PATH}"
        echo ""
        echo " The Calib_PATH variable does not indicate the correct location"
        echo " of the calibration software."
        echo " Find the directory with calibration software in your system."
        echo " Next find .calib_phot_bialkow_rc file,"
        echo " correct it, if necessary, and type in terminal:"
        echo " source <path_to_file>/.calib_phot_bialkow_rc"
        echo ""
        exit
    fi
else
    echo " The Calib_PATH variable is empty,"
    echo " find .calib_phot_bialkow_rc file in your system,"
    echo " correct it, if necessary, and type in terminal:"
    echo " source <path_to_file>/.calib_phot_bialkow_rc"
    echo ""
    exit
fi

declare -A ff_file=()
for f in filter_seq
    do
    ff_file[$f]=""
done

if test ! -d  ${AUX_FILES_DIR}
    then
    echo " Directory ${AUX_FILES_DIR} does not exist"
    echo " It should contain auxiliary calibration files, e.g. master dark, average fringing, arcs ..."
    exit
fi

if test ! -s ${AUX_FILES_DIR}/${long_dark_2}
    then
    echo " File ${long_dark_2} does not exist in directory ${AUX_FILES_DIR}"
    exit
fi

if test ! -s ${AUX_FILES_DIR}/${long_dark_16}
    then
    echo " File ${long_dark_16} does not exist in directory ${AUX_FILES_DIR}"
    exit
fi

if test ! -d  ${CALIB_FILES_DIR}
    then
    mkdir ${CALIB_FILES_DIR}
fi
if test ! -d  ${CDATA_DIR}
    then
    mkdir ${CDATA_DIR}
fi

if test -e ff-ev.log
    then
    rm ff-ev.log
fi
if test -e ff-mo.log
    then
    rm ff-mo.log
fi

if test ! -s login.cl
    then
    if test -s ${HOME}/login.cl
        then
        cp ${HOME}/login.cl .
    else
        echo " IRAF configuration file login.cl not found !"
        echo " Find it or create (command mkiraf)"
        exit
    fi
fi

if test -s ${AUX_FILES_DIR}/bias_16_interp.plt
    then
    cp ${AUX_FILES_DIR}/bias_16_interp.plt .
else
    echo "Warning: ${AUX_FILES_DIR}/bias_16_interp.plt file not found !"
fi
if test -s ${AUX_FILES_DIR}/bias_2_interp.plt
    then
    cp ${AUX_FILES_DIR}/bias_2_interp.plt .
else
    echo "Warning: ${AUX_FILES_DIR}/bias_2_interp.plt file not found !"
fi

# Make new logfile when l option used:
if test "$2" = "l"
    then

    if test ! -s ${Calib_PATH}/pyfits_mk_log.py
        then
        echo " Script pyfits_mk_log.py does not exist in ${Calib_PATH} directory !"
        exit
    fi

    n_fits=`ls *.fits | wc -l`
    if test ${n_fits} -le ${min_fits_files}
        then
        echo " Number of FITS files in the current directory ${PWD}"
        echo " is too small: ${n_fits}"
        exit
    fi

    ls -tr *.fits | pyfits_mk_log.py -l ${logfile}

    echo " Log-file  ${logfile}  done."

else

    if test ! -s ${logfile}
        then
        echo " ${logfile} not found !"
        echo " Use l option to create new log file."
        exit
    fi

fi

# sorting logfile in the chronological order:
sort -n -k 13 ${logfile} > tmp_log
mv tmp_log ${logfile}

${edit} ${logfile}

pyraf_hedit_add_expt.py ${logfile}

################################
echo ""
echo "----------------------"
echo "  Making FLAT-FIELDS"
echo "----------------------"
echo ""
################################

ffx=0

################
# Evening flats:
 
if test `ls ff-ev*.fits | wc -l` -gt 0
    then
    echo ""
    echo " Evening flats"
    echo ""

    grep ff-ev ${logfile} | grep DARK | awk '{print $1}' > ff-ev-dark.cat
    grep ff-ev ${logfile} | grep BIAS | awk '{print $1}' > ff-ev-bias.cat

    if test `cat ff-ev-dark.cat | wc -l` -gt 3
        then
        pyraf_zerocombine.py @ff-ev-dark.cat ff-ev-dark.fits
    fi
    if test `cat ff-ev-bias.cat | wc -l` -gt 3
        then
        pyraf_zerocombine.py @ff-ev-bias.cat ff-ev-bias.fits
    fi

    if test -e ff-ev-bias.fits
        then
        zero_ev="ff-ev-bias.fits"
    fi
    if test -e ff-ev-dark.fits
        then
        zero_ev="ff-ev-dark.fits"
    fi

    if test -s ${zero_ev}
        then
        echo "using evening zero ${zero_ev}"
        grep ff-ev ${logfile} | grep FLAT| awk '{print $1}' > ff-ev-flat.cat

        pyraf_imstat.py @ff-ev-flat.cat > ff-ev-flat.sts
        cp ff-ev-flat.sts ${CALIB_FILES_DIR}

        awk 'BEGIN {max='${flat_max_v}'; min='${flat_min_v}'}; $1~ /.fits/ && $3>min && $3<max {print $1}' ff-ev-flat.sts > ff-ev-flat-ok.cat
        for i in `cat ff-ev-flat-ok.cat` ; do grep $i ${logfile} ; done  > ff-ev.log
        grep ff-ev ff-ev.log | grep FLAT| awk '{print $1}' | sed -e 's,.fits,-t.fits,' > ff-ev-flat-t.cat
        grep ff-ev ff-ev.log | grep FLAT| awk '{print $1}' | sed -e 's,.fits,-bt.fits,' > ff-ev-flat-bt.cat
        pyraf_ccdproc_zerocor_trim.py @ff-ev-flat-ok.cat @ff-ev-flat-t.cat @ff-ev-flat-bt.cat $zero_ev

        for f in ${filter_seq}
            do
            grep ff-ev ff-ev.log | grep FLAT | awk ' $10~ /'${f}'/ {print $1}' | sed -e 's,.fits,-bt.fits,'  > flat${f}-ev.cat

            if test `cat flat${f}-ev.cat | wc -l` -ge ${min_good_flats}
                then
                pyraf_flatcombine.py @flat${f}-ev.cat flat${f}-ev.fits
                cp flat${f}-ev.fits ${CALIB_FILES_DIR}
            fi
        done
    fi
fi

################
# Morning flats:

if test `ls ff-mo*.fits | wc -l` -gt 0
then
echo ""
echo " Morning flats"
echo ""

grep ff-mo ${logfile} | grep DARK | awk '{print $1}' > ff-mo-dark.cat
grep ff-mo ${logfile} | grep BIAS | awk '{print $1}' > ff-mo-bias.cat

if test `cat ff-mo-dark.cat |wc -l` -gt 3
then
pyraf_zerocombine.py @ff-mo-dark.cat ff-mo-dark.fits
fi
if test `cat ff-mo-bias.cat |wc -l` -gt 3
then
pyraf_zerocombine.py @ff-mo-bias.cat ff-mo-bias.fits
fi

if test -e ff-mo-bias.fits
then
zero_mo="ff-mo-bias.fits"
fi
if test -e ff-mo-dark.fits
then
zero_mo="ff-mo-dark.fits"
fi

if test -s ${zero_mo}
then

echo "using morning zero ${zero_ev}"

grep ff-mo ${logfile} | grep FLAT | awk '{print $1}' > ff-mo-flat.cat
pyraf_imstat.py @ff-mo-flat.cat > ff-mo-flat.sts
cp ff-mo-flat.sts ${CALIB_FILES_DIR}

awk 'BEGIN {max='${flat_max_v}'; min='${flat_min_v}'}; $1~ /.fits/ && $3>min && $3<max {print $1}' ff-mo-flat.sts > ff-mo-flat-ok.cat
for i in `cat ff-mo-flat-ok.cat` ; do grep $i ${logfile} >> ff-mo.log ; done
grep ff-mo ff-mo.log | grep FLAT | awk '{print $1}' | sed -e 's,.fits,-t.fits,' > ff-mo-flat-t.cat
grep ff-mo ff-mo.log | grep FLAT | awk '{print $1}' | sed -e 's,.fits,-bt.fits,' > ff-mo-flat-bt.cat
pyraf_ccdproc_zerocor_trim.py @ff-mo-flat-ok.cat @ff-mo-flat-t.cat @ff-mo-flat-bt.cat $zero_mo

for f in  ${filter_seq}
do
grep ff-mo ff-mo.log | grep FLAT | awk ' $10~ /'${f}'/ {print $1}' | sed -e 's,.fits,-bt.fits,' > flat${f}-mo.cat

if test `cat flat${f}-mo.cat | wc -l` -ge ${min_good_flats}
then
pyraf_flatcombine.py @flat${f}-mo.cat flat${f}-mo.fits
cp flat${f}-mo.fits ${CALIB_FILES_DIR}
fi
done

fi
fi
rm ff-*-t.fits

########################
# Compare flat-fields:

for f in  ${filter_seq}
do
if test -e flat${f}-mo.fits -a -e flat${f}-ev.fits
then
ls flat${f}-mo.fits flat${f}-ev.fits > flat${f}-ev-mo.cat
# Average FF (evening + morning)
pyraf_flatcombine_ev_mo.py @flat${f}-ev-mo.cat flat${f}-ev-mo.fits
cp flat${f}-ev-mo.fits ${CALIB_FILES_DIR}

##  FF control pictures (morning / evening normalized to 1)
pyraf_imarith_flatdiv.py flat${f}-mo.fits flat${f}-ev.fits ff${f}-div.fits
pyraf_imstat.py ff${f}-div.fits >  ff${f}-div.sts
avdiv=`awk '$1~ /.fits/ {printf("%8.3f\n", $3)}' ff${f}-div.sts`
pyraf_imarith_flatdiv.py ff${f}-div.fits $avdiv ff${f}-div-norm.fits
pyraf_imstat.py ff${f}-div-norm.fits > ff${f}-div.sts

# FITS to JPEG conversion 
fits2png.py ff${f}-div-norm.fits ff${f}-div-norm.png > fits2png.log
pngtopnm ff${f}-div-norm.png > ff${f}-div-norm.pnm
pnmscale 0.5 ff${f}-div-norm.pnm > tmp.pnm
mv tmp.pnm ff${f}-div-norm.pnm
pnmtojpeg ff${f}-div-norm.pnm > ff${f}-div-norm.jpg
z1=`grep 'auto z1' fits2png.log | sed -e 's/,//g' | awk '{printf("%.4f",$5)}'`
z2=`grep 'auto z2' fits2png.log | sed -e 's/,//g' | awk '{printf("%.4f",$5)}'`
zp=`awk 'BEGIN {z1='${z1}'; z2='${z2}'; printf("%.2f",(z2-z1)*100.0 ) }'` 
rm ff${f}-div-norm.png ff${f}-div-norm.pnm
convert -font Helvetica -pointsize 34 -fill blue -draw "text 40,35 'Min ${z1}, Max ${z2}, var. ${zp}%'" ff${f}-div-norm.jpg tmp.jpg 
mv tmp.jpg ff${f}-div-norm.jpg
mv ff${f}-div-norm.* ${CALIB_FILES_DIR}

##
echo ""
echo " Flat-field morning/evening control picture ff${f}-div-norm"
echo " stored in directory ${CALIB_FILES_DIR}"
echo ""

fi

if test -s flat${f}-ev-mo.fits
then
ff_file[${f}]="flat${f}-ev-mo.fits"
ffx=1
elif test -s flat${f}-ev.fits
then
ff_file[${f}]="flat${f}-ev.fits"
ffx=1
elif test -s flat${f}-mo.fits
then
ff_file[${f}]="flat${f}-mo.fits"
ffx=1
else
echo " Warning: There is no FLAT-FIELD in ${f} filter !"
ff_file[${f}]=""
fi
done

if test ${ffx} -eq 0
then
echo ""
echo " !! There are no FLAT-FIELDS in the current directory !!"
echo ""
exit
fi

#######################
echo ""
echo " ======================================"
echo "  Calibration of OBJECT/SCIENCE images"
echo " ======================================"
echo ""
#######################
echo ""
echo " ------------------"
echo "  BIAS subtraction"
echo "-------------------"
echo ""

## 
echo " readout speed 2"

awk '/OBJECT/ && $9==2 {print $1}' ${logfile} > object_2.cat
n_obj_2=`cat object_2.cat | wc -l`
echo " ${n_obj_2} images"

awk '/OBJECT/ && $9==2 {printf("%s %f %d\n",$1,$(NF)-int($(NF)),$8)}' ${logfile} > object_2.data
cat object_2.cat| sed -e 's,.fits,-b1.fits,' > object-b_2.cat
cat object_2.cat| sed -e 's,.fits,-b.fits,' > object-bias_2.cat
grep BIAS ${logfile} | awk '$9==2 {print $1}'  > night-bias_2.cat
cat  night-bias_2.cat | sed -e 's,.fits,-b.fits,' > night-bias-diff_2.cat

if test `cat object_2.cat | wc -l` -gt 0
then
if test `cat night-bias_2.cat | wc -l` -gt 1
then
pyraf_zerocombine_night.py @night-bias_2.cat night-bias_av_2.fits
cp night-bias_av_2.fits ${CALIB_FILES_DIR}

if test -s night-bias_av_2.fits
then
pyraf_imarith_zerosub.py @night-bias_2.cat night-bias_av_2.fits @night-bias-diff_2.cat
else
echo " Script execution terminated !"
echo ' The average BIAS image (night-bias_av_2.fits) not found in the current directory '
exit
fi

pyraf_imstat.py @night-bias-diff_2.cat > night-bias-diff_2.sts

gawk 'BEGIN {i=0; while(getline < "night-bias-diff_2.sts") {if($1!="#") {nm[++i]=$1; mean[i]=$3}}}; {for(l=1; l<=i; l++) if($1==gensub(/-b.fits/,".fits","g",nm[l])) printf("%-20s %8.5f %8.2f\n",nm[l],$(NF)-int($(NF)),mean[l])}' ${logfile} > night-bias-diff_2.data

bias_interp.py night-bias-diff_2.data object_2.data > object_2_bias_interp.data
awk '{print $3}' object_2_bias_interp.data > diffbias_2

pyraf_imarith_zerosub.py @object_2.cat night-bias_av_2.fits @object-b_2.cat
pyraf_imarith_zerosub.py @object-b_2.cat @diffbias_2 @object-bias_2.cat

gnuplot bias_2_interp.plt
cp object_2_bias_interp.data diffbias_2 bias_2_interp.ps ${CALIB_FILES_DIR}

else
echo " Script execution terminated !"
echo " Too small number of BIAS images with readout speed 2 !"
exit
fi
rm *-b1.fits
fi

## 
echo " readout speed 16"

awk '/OBJECT/ && $9==16 {print $1}' ${logfile} > object_16.cat

n_obj_16=`cat object_16.cat | wc -l`
echo " ${n_obj_16} images"

awk '/OBJECT/ && $9==16 {printf("%s %f %d\n",$1,$(NF)-int($(NF)),$8)}' ${logfile} > object_16.data
cat object_16.cat| sed -e 's,.fits,-b1.fits,' > object-b_16.cat
cat object_16.cat| sed -e 's,.fits,-b.fits,' > object-bias_16.cat
grep BIAS ${logfile} | awk '$9==16 {print $1}'  > night-bias_16.cat
cat  night-bias_16.cat | sed -e 's,.fits,-b.fits,' > night-bias-diff_16.cat

if test `cat object_16.cat | wc -l` -gt 0
then
if test `cat night-bias_16.cat | wc -l` -gt 1
then
pyraf_zerocombine_night.py @night-bias_16.cat night-bias_av_16.fits
cp night-bias_av_16.fits ${CALIB_FILES_DIR}

if test -s night-bias_av_16.fits
then
pyraf_imarith_zerosub.py @night-bias_16.cat night-bias_av_16.fits @night-bias-diff_16.cat
else

echo " Script execution terminated !"
echo ' The average BIAS image (night-bias_av_16.fits) not found in the current directory'
exit
fi

pyraf_imstat.py @night-bias-diff_16.cat > night-bias-diff_16.sts

gawk 'BEGIN {i=0; while(getline < "night-bias-diff_16.sts") {if($1!="#") {nm[++i]=$1; mean[i]=$3}}}; {for(l=1; l<=i; l++) if($1==gensub(/-b.fits/,".fits","g",nm[l])) printf("%-20s %8.5f %8.2f\n",nm[l],$(NF)-int($(NF)),mean[l])}' ${logfile} > night-bias-diff_16.data

bias_interp.py night-bias-diff_16.data object_16.data > object_16_bias_interp.data
awk '{print $3}' object_16_bias_interp.data > diffbias_16
pyraf_imarith_zerosub.py @object_16.cat night-bias_av_16.fits @object-b_16.cat
pyraf_imarith_zerosub.py @object-b_16.cat @diffbias_16 @object-bias_16.cat

gnuplot bias_16_interp.plt 
cp object_16_bias_interp.data diffbias_16 bias_16_interp.ps ${CALIB_FILES_DIR}

else
echo " Script execution terminated !"
echo " Too small number of BIAS images with readout speed 16"
exit
fi
rm *-b1.fits
fi

#########################
echo  " -------------------"
echo  "  DARK subtraction"
echo  " -------------------"
#########################

##
echo ""
echo " readout_speed 2"
echo ""
##

cp ${AUX_FILES_DIR}/${long_dark_2} .

grep OBJECT ${logfile} | awk 'BEGIN {m_dark="'${long_dark_2}'"; m_dark_exp="'${long_dark_2_exp}'"; ldt='${lim_dark_time}'}; $8 >= ldt && $9 == 2 {ff=sprintf("obj_2_exp%s.cat",$8); fd=sprintf("obj_2_exp%s_d.cat",$8); sub(/.fits/,"-b.fits",$1); print $1 > ff; sub(/-b.fits/,"-bd.fits",$1) ; print $1 > fd ; ++t[$8]}; END {for(l in t) {print l > "dark_exp_2" ; printf("pyraf_imarith_scl_dark.py %s %s %s dark2_expt%s.fits\n",m_dark,l,m_dark_exp,l)}}' | bash

if test `cat  dark_exp_2 | wc -l` -gt 0
then
for d in `cat dark_exp_2`
do
if test `cat obj_2_exp${d}.cat | wc -l` -gt 0
then
pyraf_ccdproc_darksub.py @obj_2_exp${d}.cat @obj_2_exp${d}_d.cat dark2_expt${d}.fits
cp dark2_expt${d}.fits ${CALIB_FILES_DIR}
fi
done
rm dark_exp_2
fi

## 
echo ""
echo " readout_speed 16"
echo ""
##

cp ${AUX_FILES_DIR}/${long_dark_16} .

grep OBJECT ${logfile} | awk 'BEGIN {m_dark="'${long_dark_16}'"; m_dark_exp="'${long_dark_16_exp}'"; ldt='${lim_dark_time}'}; $8 >= ldt && $9 == 16 {ff=sprintf("obj_16_exp%s.cat",$8); fd=sprintf("obj_16_exp%s_d.cat",$8); sub(/.fits/,"-b.fits",$1); print $1 > ff; sub(/-b.fits/,"-bd.fits",$1) ; print $1 > fd ; ++t[$8]}; END {for(l in t) {print l > "dark_exp_16" ; printf("pyraf_imarith_scl_dark.py %s %s %s dark16_expt%s.fits\n",m_dark,l,m_dark_exp,l)}}' | bash

if test `cat  dark_exp_16 | wc -l` -gt 0
then
for d in `cat dark_exp_16`
do
if test `cat obj_16_exp$d.cat | wc -l` -gt 0
then
pyraf_ccdproc_darksub.py @obj_16_exp${d}.cat @obj_16_exp${d}_d.cat dark16_expt${d}.fits
cp dark16_expt${d}.fits ${CALIB_FILES_DIR}
fi
done
rm dark_exp_16
fi

############################
echo ""
echo "-----------------------"
echo " FLAT-FIELD correction"
echo "-----------------------"
echo ""
############################

for f in ${filter_seq}
do
export f 
grep OBJECT ${logfile} | awk '$10~ /'${f}'/ && $8 < '${lim_dark_time}' {print $1}' | sed -e 's,.fits,-b.fits,' > object-${f}-b.cat
grep OBJECT ${logfile} | awk '$10~ /'${f}'/ && $8 >= '${lim_dark_time}' {print $1}' | sed -e 's,.fits,-bd.fits,' >> object-${f}-b.cat
cat object-${f}-b.cat | sed -e 's,-b.fits,-btf.fits,' -e 's,-bd.fits,-bdtf.fits,' > object-${f}-btf.cat

if test -n "${ff_file[$f]}"
then
if test `cat  object-${f}-b.cat |wc -l` -ge 1
then 
pyraf_ccdproc_trim_flatcor.py @object-${f}-b.cat @object-${f}-btf.cat ${ff_file[$f]}
nobs=`wc -l object-${f}-b.cat | awk '{print $1}'`
echo " ${nobs} observations in ${f} filter calibrated..."
fi
fi
done

cp ${logfile} ${CDATA_DIR}
mv *-btf.fits ${CDATA_DIR}
mv *-bdtf.fits ${CDATA_DIR}

rm night-bias* diffbias* *-b.fits *-b[dt].fits *.cat *.ps *.sts *.data *.plt
rm dark*.fits Dark*fits

echo ""
echo " ==========================================================================="
echo "  Calibration data are stored in the ${CALIB_FILES_DIR} directory."
echo "  All calibrated science images are stored in the ${CDATA_DIR} directory."
echo " ==========================================================================="
echo ""

# End of script.
