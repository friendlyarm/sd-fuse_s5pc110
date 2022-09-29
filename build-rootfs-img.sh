#!/bin/bash
set -eux

if [ $# -lt 2 ]; then
	echo "Usage: $0 <rootfs dir> <img filename> "
    echo "example:"
    echo "    tar xvzf NETDISK/S5PC110/rootfs/rootfs_qtopia_qt4.tgz"
    echo "    ./build-rootfs-img.sh rootfs_qtopia_qt4 friendlycore"
	exit 0
fi

#----------------------------------------------------------
# base setup

ROOTFS_DIR=$1
TARGET_OS=$2
IMG_FILE=$TARGET_OS/rootfs.img

[ $# -eq 3 ] && IMG_SIZE=$3
true ${IMG_SIZE:=536870912}

TOP=$PWD
true ${MKFS:="${TOP}/tools/make_ext4fs"}

if [ ! -d "${ROOTFS_DIR}" ]; then
	echo "path '${ROOTFS_DIR}' not found."
	exit 1
fi

# Automatically re-run script under sudo if not root
if [ $(id -u) -ne 0 ]; then
	echo "Re-running script under sudo..."
	sudo "$0" "$@"
	exit
fi

function clear_rootfs()
{
	(cd ${ROOTFS_DIR} && {
		find ./dev ! -type d -exec rm {} \;
		rm -f etc/pointercal
		rm -f etc/fs.resized
		rm -f etc/ts.detected
		mkdir -p ./tmp
		chmod 1777 ./tmp
		if [ -d var/tmp ]; then
			find var/tmp -type f -delete
		fi
		if [ -d var/log ]; then
			find var/log -type f -delete
		fi
	})
}

#----------------------------------------------------------
# Make ext4 image
clear_rootfs
${MKFS} -s -l ${IMG_SIZE} -a root -L rootfs ${IMG_FILE} ${ROOTFS_DIR}
if [ $? -ne 0 ]; then
	echo "error: failed to  make rootfs.img."
	exit 1
fi

echo "generating ${IMG_FILE} done."
echo 0


