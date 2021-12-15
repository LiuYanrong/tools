#!/bin/bash

CURR_DIR=`pwd`
if [[ $# -eq 1 ]]; then
	cd ${1}
	echo "cd ${1}"
fi

LS="ls"
DU="du"
if [[ `whoami` == "root" ]]; then
	LS="sudo ls"
	DU="sudo du"
fi

echo $DU $LS

for i in `ls`; do
	if [[ -f "$i" ]]; then
		RET=`$LS -h $i`		
		echo "FILE    "$RET
		
	elif [[ -d "$i" ]]; then
		RET=`$DU -h $i | tail -n 1`
		echo "DIR     "$RET
	fi
	
done

if [[ $# -eq 1 ]]; then
	cd $CURR_DIR
	echo "cd $CURR_DIR"
fi
