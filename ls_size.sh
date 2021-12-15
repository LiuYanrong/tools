#!/bin/bash

CURR_DIR=`pwd`
if [[ $# -eq 1 ]]; then
	cd ${1}
	echo "cd ${1}"
fi



USER=`whoami`
echo $USER

exit 1

LS=`ls`
DU=`du`

for i in `$LS`; do
	if [[ -f "$i" ]]; then
		RET=`$DU -h $i`		
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

