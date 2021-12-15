#!/bin/bash

CURR_DIR=`pwd`
if [[ $# -eq 1 ]]; then
	cd ${1}
	echo "cd ${1}"
fi

for i in `ls`; do
	if [[ -f "$i" ]]; then
		RET=`du -h $i`		
		echo "FILE    "$RET
		
	elif [[ -d "$i" ]]; then
		RET=`du -h $i | tail -n 1`
		echo "DIR     "$RET
	fi
	
done

if [[ $# -eq 1 ]]; then
	cd $CURR_DIR
	echo "cd $CURR_DIR"
fi

