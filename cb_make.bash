#!/usr/bin/env bash

## retrive CalibBialkow dir (dir of this script)
pushd `dirname $0` > /dev/null
CALIBBLIALKOW_PATH=`pwd`
popd > /dev/null


MAKE_TARGET=""
FITS_PATH="."

while [[ $# > 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
        echo " Script cb_make.bash"
        echo " the calibration pipeline for ANDOR CCD images from Bialkow Observatory"
        echo " make - way version"
        echo ""
        echo " Usage: cb_make.bash [-h|--help] [target]"
        echo "       Targets:"
        echo "          calib   - (default) make full calibration"
        echo "          log     - create DO: night.log"
        echo "          flat    - makes FLAT-FIELD proessing only"
        echo " requirements: python 2.6+ with[PyRAF, PyFITS, argparse], gawk, bash4.0+"
        echo " and all scripts included in directory ${CALIBBLIALKOW_PATH}"
        echo ""
        echo " FITS files in the current directory (with .fits extension)."
        echo " Use cb_make_recursive to cb_make in all subdirectories"
        echo " Version: 2016.04.16, (ZK)"
        echo ""
        exit
        ;;
        -s|--searchpath)
        SEARCHPATH="$2"
        shift # past argument
        ;;
        -d|--data)
        FITS_PATH="$2"
        shift # past argument
        ;;
        --default)
        DEFAULT=YES
        ;;
        *)
        MAKE_TARGET="$1"
        ;;
    esac
    shift # past argument or value
done

export FITS_PATH

echo "Target: ${MAKE_TARGET}"
echo "Calib_PATH: ${CALIBBLIALKOW_PATH}"
echo "FITS_PATH: ${FITS_PATH}"
make -f ${CALIBBLIALKOW_PATH}/calib.makefile ${MAKE_TARGET}