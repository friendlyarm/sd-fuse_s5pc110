#!/bin/bash
set -eu

[ -f ${PWD}/mk-sd-image.sh ] || {
	echo "Error: please run at the script's home dir"
	exit 1
}

if [ $# -ne 2 ]; then
	echo "number of args must be 2"
	exit 1
fi

cp -af $1/u-boot-sd.bin $2
cp -af $1/u-boot-onenand.bin $2/boot/images/Linux/
exit $?
