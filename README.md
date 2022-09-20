# sd-fuse_s5pc110
Create bootable SD card for TinyC110, used to install the system into onenand

## Usage
### Re-pack SD image from binary files
```
git clone https://github.com/friendlyarm/sd-fuse_s5pc110.git
cd sd-fuse_s5pc110
wget http://112.124.9.243/dvdfiles/S5PC110/images-for-sd_fuse/friendlycore-images.tgz
tar xzf friendlycore-images.tgz
wget http://112.124.9.243/dvdfiles/S5PC110/rootfs/rootfs-friendlycore.tgz
tar xzf rootfs-friendlycore.tgz

# The following files can be replaced with the image files you want to burn
rm -rf friendlycore/boot/*
wget http://112.124.9.243/dvdfiles/S5PC110/images-for-onenand/linux-images.tgz
tar xzf linux-images.tgz -C friendlycore/boot

# re-gen boot.img
./build-boot-img.sh friendlycore/boot friendlycore/boot.img
# re-gen rootfs.img
./build-rootfs-img.sh friendlycore/rootfs friendlycore
# re-pack sd img
sudo ./mk-sd-image.sh friendlycore
```
### Make rootfs to img and then re-pack SD image
```
git clone https://github.com/friendlyarm/sd-fuse_s5pc110.git
cd sd-fuse_s5pc110
wget http://112.124.9.243/dvdfiles/S5PC110/images-for-sd_fuse/friendlycore-images.tgz
tar xzf friendlycore-images.tgz
wget http://112.124.9.243/dvdfiles/S5PC110/rootfs/rootfs-friendlycore.tgz
tar xzf rootfs-friendlycore.tgz
rm -rf friendlycore/boot/*
wget http://112.124.9.243/dvdfiles/S5PC110/images-for-onenand/linux-images.tgz
tar xzf linux-images.tgz -C friendlycore/boot

# build kernel-3.0.8
wget http://112.124.9.243/dvdfiles/S5PC110/linux/linux-3.0.8-20190102.tgz
rm -rf linux-3.0.8
tar xzf linux-3.0.8-20190102.tgz
[ -d /opt/FriendlyARM/toolschain/4.5.1/bin ] || {
	echo "please setup toolchain 4.5.1 first."
	exit 1
}
export PATH=/opt/FriendlyARM/toolschain/4.5.1/bin:$PATH
(cd linux-3.0.8 && {
	cp arch/arm/configs/tinyc110_linux_defconfig .config
	make -j${nproc} zImage
})
cp linux-3.0.8/arch/arm/boot/zImage friendlycore/boot/images/Linux/zImage && echo "zImage updated."

# re-make rootfs_qtopia_qt4.img
wget http://112.124.9.243/dvdfiles/S5PC110/linux/rootfs_qtopia_qt4-20171109.tgz
sudo rm -rf rootfs_tinyc110
sudo tar xzf rootfs_qtopia_qt4-20171109.tgz
[ -c rootfs_tinyc110/dev/console ] || sudo mknod rootfs_tinyc110/dev/console c 5 1
sudo tools/mkyaffs2image -c 4096 -s 128 rootfs_tinyc110 rootfs_qtopia_qt4.img
sudo chown ${USER} rootfs_qtopia_qt4.img
cp rootfs_qtopia_qt4.img ./friendlycore/boot/images/Linux/rootfs_qtopia_qt4.img && echo "rootfs_qtopia_qt4.img updated."

# re-gen boot.img
./build-boot-img.sh friendlycore/boot friendlycore/boot.img
# re-gen rootfs.img
./build-rootfs-img.sh friendlycore/rootfs friendlycore
# re-pack sd img
sudo ./mk-sd-image.sh friendlycore
```