#!/bin/bash

CURR_DIR=`pwd`
LIST_DIR=$CURR_DIR

LS_FLAG=""
LS="ls"
DU="du"

die(){
	echo "$1"
	exit 1
}

while [ -n "$1" ]
do
  case "$1" in
    --help)
	echo "size_dir.sh"
	echo "--dir : 指定目录"
	echo "-a    : 统计隐藏目录；默认不统计"
	exit 0
	;;
    --dir)
	LIST_DIR=$2
        echo "List dir $LIST_DIR"
	shift
        ;;
    -a)
	LS_FLAG="-a"
	;;
    *)
	if [[ $# -eq 1 ]];then
        	die "$1 is unknown parameter!"
	fi
        ;;
  esac
  shift
done

if [[ $# -eq 1 ]]; then
	LIST_DIR=${1}
fi


if [[ `whoami` == "root" ]]; then
	LS="sudo ls"
	DU="sudo du"
fi

cd $LIST_DIR

for i in `ls $LS_FLAG -S`; do
	if [[ $i == "." ]];then
		continue
	elif [[ $i == ".." ]];then
		continue
	elif [[ -f "$i" ]]; then
		RET=`$LS -h --size $i`		
		echo "FILE    "$RET
	elif [[ -d "$i" ]]; then
		RET=`$DU -h $i | tail -n 1`
		echo "DIR     "$RET
	fi
	
done

cd $CURR_DIR

