#!/bin/bash
set -eu

if [ -f "$(dirname "$(readlink -f "$0")")/../.use-local-r2" ]; then
    CDN_URL=http://cdn.local/friendlyelec-cdn/os-images/s5pc110/images
    ROOTFS_URL=http://cdn.local/friendlyelec-cdn/rootfs/s5pc110
else
    CDN_URL=https://downloads.friendlyelec.com/os-images/s5pc110/images
    ROOTFS_URL=https://downloads.friendlyelec.com/rootfs/s5pc110
fi
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
wget ${CDN_URL}/friendlycore-images.tgz
tar xzf friendlycore-images.tgz

# re-build kernel
./build-kernel.sh friendlycore

# re-build uboot
./build-uboot.sh friendlycore

# download rootfs package
wget ${ROOTFS_URL}/rootfs_qtopia_qt4.tgz
wget ${ROOTFS_URL}/rootfs_qtopia_qt4.tgz.sha256
sha256sum -c rootfs_qtopia_qt4.tgz.sha256
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
