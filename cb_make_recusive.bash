#!/usr/bin/env bash


if [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
	echo "Executes cm_make in all subdirectories"
	echo "Type:"
	echo "   cm_make --help"
	echo "for more help."
	exit
fi


for dir in ./*/; do
	echo ""
	echo "#######################################"
	echo "Entering directory: ${dir}"
	echo "#######################################"
	echo ""
	pushd ${dir} > /dev/null
	cb_make.bash "$@"
	popd > /dev/null
done

