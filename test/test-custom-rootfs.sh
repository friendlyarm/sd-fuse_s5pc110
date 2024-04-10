#!/bin/bash
set -eu

HTTP_SERVER=112.124.9.243

# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

case "$(uname -mpi)" in
x86_64*)
	;;
*)
	echo "Error: only supports x86_64."
	exit 1
	;;
esac

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5pc110
cd sd-fuse_s5pc110
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5PC110/images/friendlycore-images.tgz
tar xzf friendlycore-images.tgz

# re-build kernel
./build-kernel.sh friendlycore

# re-build uboot
./build-uboot.sh friendlycore

# download rootfs package
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5PC110/rootfs/rootfs_qtopia_qt4.tgz
sudo rm -rf rootfs_qtopia_qt4
sudo tar xzf rootfs_qtopia_qt4.tgz
[ -c rootfs_qtopia_qt4/dev/console ] || sudo mknod rootfs_qtopia_qt4/dev/console c 5 1

# re-make rootfs_qtopia_qt4.img for onenand
sudo tools/mkyaffs2image -c 4096 -s 128 rootfs_qtopia_qt4 rootfs_qtopia_qt4.img
sudo chown ${USER} rootfs_qtopia_qt4.img
cp rootfs_qtopia_qt4.img ./friendlycore/boot/images/Linux/rootfs_qtopia_qt4.img && echo "rootfs_qtopia_qt4.img updated."

# re-make rootfs.img for sd boot
./build-rootfs-img.sh rootfs_qtopia_qt4 friendlycore && echo "rootfs.img updated."

sudo ./mk-sd-image.sh friendlycore
