#!/bin/bash
set -eu

function has_built_uboot() {
	if [ -f $1/u-boot-sd.bin ]; then
		echo 1
	else
		echo 0
	fi
}

function has_built_kernel() {
	local ARCH=arm
	local KIMG=arch/${ARCH}/boot/zImage-dtb
	if [ -f $1/${KIMG} ]; then
		echo 1
	else
		echo 0
	fi
}

function has_built_kernel_modules() {
	local OUTDIR=${2}
	local SOC=s5pc110
	if [ -d ${OUTDIR}/output_${SOC}_kmodules ]; then
		echo 1
	else
		echo 0
	fi
}

function check_and_install_package() {
	local PACKAGES=
	if ! command -v mkfs.exfat &>/dev/null; then
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			case "$VERSION_CODENAME" in
			jammy|bookworm|bullseye)
					PACKAGES="exfatprogs exfat-fuse ${PACKAGES}"
					;;
			*)
					PACKAGES="exfat-fuse exfat-utils ${PACKAGES}"
					;;
			esac
		fi

	fi
	if ! [ -x "$(command -v simg2img)" ]; then
		if [ -f /etc/os-release ]; then
			. /etc/os-release
			case "$VERSION_CODENAME" in
			focal|jammy|bookworm|bullseye)
					PACKAGES="android-sdk-libsparse-utils ${PACKAGES}"
					# PACKAGES="android-sdk-ext4-utils ${PACKAGES}"
					;;
			*)
					PACKAGES="android-tools-fsutils ${PACKAGES}"
					;;
			esac
		fi
	fi
	if ! [ -x "$(command -v swig)" ]; then
		PACKAGES="swig ${PACKAGES}"
	fi
	if ! [ -x "$(command -v git)" ]; then
		PACKAGES="git ${PACKAGES}"
	fi
	if ! [ -x "$(command -v wget)" ]; then
		PACKAGES="wget ${PACKAGES}"
	fi
	if ! [ -x "$(command -v rsync)" ]; then
		PACKAGES="rsync ${PACKAGES}"
	fi
	if ! [ -x "$(command -v mkfs.vfat)" ]; then
		PACKAGES="dosfstools ${PACKAGES}"
	fi
	if ! command -v partprobe &>/dev/null; then
		PACKAGES="parted ${PACKAGES}"
	fi
	if ! command -v sfdisk &>/dev/null; then
		PACKAGES="fdisk ${PACKAGES}"
	fi
	if ! command -v resize2fs &>/dev/null; then
		PACKAGES="e2fsprogs ${PACKAGES}"
	fi
	if [ ! -z "${PACKAGES}" ]; then
		sudo apt install ${PACKAGES}
	fi
}

function check_and_install_toolchain() {
	case "$(uname -mpi)" in
	x86_64*)
		if [ ! -d /opt/FriendlyARM/toolchain/4.5.1 ]; then
			echo "please install arm-linux-gcc 4.5.1 first by running these commands: "
			echo "\tgit clone https://github.com/friendlyarm/prebuilts.git --depth 1 -b master"
			echo "\tsudo mkdir -p /opt/FriendlyARM/toolchain"
			echo "\tsudo tar xf prebuilts/gcc/arm-linux-gcc-4.5.1-v6-vfp.tar.xz -C /opt/FriendlyARM/toolchain/ --strip-components 3"
			exit 1
		fi
		export PATH=/opt/FriendlyARM/toolchain/4.5.1/bin/:$PATH
		return 0
		;;
	*)
		echo "Error: cannot build armhf binary on this platform, only supports x86_64."
		;;
	esac
	return 1
}
