#!/bin/bash
set -eu

[ -f ${PWD}/mk-sd-image.sh ] || {
	echo "Error: please run at the script's home dir"
	exit 1
}

true ${SOC:=s5pc110}
ARCH=arm
KIMG=arch/${ARCH}/boot/zImage-dtb
OUT=${PWD}/out

UBOOT_DIR=$1
KERNEL_DIR=$2
BOOT_DIR=$3
ROOTFS_DIR=$4
PREBUILT=$5
TARGET_OS=$6

KMODULES_OUTDIR="${OUT}/output_${SOC}_kmodules"

# boot
rsync -a --no-o --no-g ${PREBUILT}/boot/* ${BOOT_DIR}

# kernel
rsync -a --no-o --no-g ${KERNEL_DIR}/${KIMG} ${BOOT_DIR}/images/Linux/

# rootfs
rm -rf ${ROOTFS_DIR}/lib/modules/*
cp -af ${KMODULES_OUTDIR}/* ${ROOTFS_DIR}

exit 0
