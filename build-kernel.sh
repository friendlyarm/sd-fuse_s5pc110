#!/bin/bash
set -eu

# Copyright (C) Guangzhou FriendlyARM Computer Tech. Co., Ltd.
# (http://www.friendlyarm.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, you can access it online at
# http://www.gnu.org/licenses/gpl-2.0.html.

true ${SOC:=s5pc110}

KERNEL_REPO=https://github.com/friendlyarm/linux
KERNEL_BRANCH=tinyc110-v3.0.8

ARCH=arm
true ${KCFG_ONENAND:=tinyc110_linux_defconfig}
true ${KCFG_SD:=tinyc110-mmcboot_linux_defconfig}
CROSS_COMPILE=arm-linux-

TOPPATH=$PWD
OUT=$TOPPATH/out
if [ ! -d $OUT ]; then
	echo "path not found: $OUT"
	exit 1
fi
true ${kernel_src:=${OUT}/kernel-${SOC}}
true ${KERNEL_SRC:=${kernel_src}}

function usage() {
       echo "Usage: $0 <img dir>"
       echo "# example:"
       echo "# clone kernel source from github:"
       echo "    git clone ${KERNEL_REPO} --depth 1 -b ${KERNEL_BRANCH} ${KERNEL_SRC}"
       echo "# or clone your local repo:"
       echo "    git clone git@192.168.1.2:/path/to/linux.git --depth 1 -b ${KERNEL_BRANCH} ${KERNEL_SRC}"
       echo "# then"
       echo "    ./build-kernel.sh friendlycore"
       echo "# also can do:"
       echo "    KERNEL_SRC=~/mykernel ./build-kernel.sh friendlycore"
       exit 0
}

if [ $# -ne 1 ]; then
    usage
fi

. ${TOPPATH}/tools/util.sh
check_and_install_toolchain
if [ $? -ne 0 ]; then
    exit 1
fi
check_and_install_package

# ----------------------------------------------------------
# Get target OS
true ${TARGET_OS:=$(echo ${1,,}|sed 's/\///g')}
PARTMAP=./${TARGET_OS}/partmap.txt

case ${TARGET_OS} in
friendlycore*)
        ;;
*)
        echo "Error: Unsupported target OS: ${TARGET_OS}"
        exit 1
esac

download_img() {
    if [ ! -f ${PARTMAP} ]; then
	ROMFILE=`./tools/get_pkg_filename.sh ${1}`
        cat << EOF
Warn: Image not found for ${1}
----------------
you may download them from the netdisk (dl.friendlyarm.com) to get a higher downloading speed,
the image files are stored in a directory called images-for-eflasher, for example:
    tar xvzf /path/to/NETDISK/images-for-eflasher/${ROMFILE}
----------------
Or, download from http (Y/N)?
EOF
        while read -r -n 1 -t 3600 -s USER_REPLY; do
            if [[ ${USER_REPLY} = [Nn] ]]; then
                echo ${USER_REPLY}
                exit 1
            elif [[ ${USER_REPLY} = [Yy] ]]; then
                echo ${USER_REPLY}
                break;
            fi
        done

        if [ -z ${USER_REPLY} ]; then
            echo "Cancelled."
            exit 1
        fi
        ./tools/get_rom.sh ${1} || exit 1
    fi
}
download_img ${TARGET_OS}

if [ ! -d ${KERNEL_SRC} ]; then
	git clone ${KERNEL_REPO} --depth 1 -b ${KERNEL_BRANCH} ${KERNEL_SRC}
fi

cd ${KERNEL_SRC}
make distclean
touch .scmversion

make ARCH=${ARCH} ${KCFG_ONENAND}
if [ $? -ne 0 ]; then
	echo "failed to config kernel for onenand."
	exit 1
fi
make ARCH=arm zImage -j$(nproc)
if [ $? -ne 0 ]; then
        echo "failed to build kernel for onenand."
        exit 1
fi
cp arch/arm/boot/zImage ${TOPPATH}/${TARGET_OS}/boot/images/Linux/zImage

make ARCH=${ARCH} ${KCFG_SD}
if [ $? -ne 0 ]; then
	echo "failed to config kernel for onenand."
	exit 1
fi
make ARCH=arm zImage -j$(nproc)
if [ $? -ne 0 ]; then
        echo "failed to build kernel for sdboot."
        exit 1
fi
cp arch/arm/boot/zImage ${TOPPATH}/${TARGET_OS}/boot/images/Linux/zImage.mmcboot

echo "building kernel ok."
