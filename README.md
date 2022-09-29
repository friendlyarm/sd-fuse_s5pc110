# sd-fuse_s5pc110
Create bootable SD card for TinyC110, used to install the system into onenand

## Usage
### Re-pack SD image from binary files
```
git clone https://github.com/friendlyarm/sd-fuse_s5pc110.git
cd sd-fuse_s5pc110
wget http://112.124.9.243/dvdfiles/S5PC110/images/friendlycore-images.tgz
tar xzf friendlycore-images.tgz
sudo ./mk-sd-image.sh friendlycore
```
### Make rootfs to img and then re-pack SD image
```
git clone https://github.com/friendlyarm/sd-fuse_s5pc110.git
cd sd-fuse_s5pc110
wget http://112.124.9.243/dvdfiles/S5PC110/images/friendlycore-images.tgz
tar xzf friendlycore-images.tgz

# download rootfs package
wget http://112.124.9.243/dvdfiles/S5PC110/rootfs/rootfs_qtopia_qt4.tgz
sudo rm -rf rootfs_qtopia_qt4
sudo tar xzf rootfs_qtopia_qt4.tgz
[ -c rootfs_qtopia_qt4/dev/console ] || sudo mknod rootfs_qtopia_qt4/dev/console c 5 1

# re-make rootfs_qtopia_qt4.img for onenand
sudo tools/mkyaffs2image -c 4096 -s 128 rootfs_qtopia_qt4 rootfs_qtopia_qt4.img
sudo chown ${USER} rootfs_qtopia_qt4.img
cp rootfs_qtopia_qt4.img ./friendlycore/boot/images/Linux/rootfs_qtopia_qt4.img && echo "rootfs_qtopia_qt4.img updated."

# re-make rootfs.img for sd boot
./build-rootfs-img.sh rootfs_qtopia_qt4 friendlycore && echo "rootfs.img updated."

# re-pack sd img
sudo ./mk-sd-image.sh friendlycore
```
### Build kernel and uboot and then re-pack SD image
```
git clone https://github.com/friendlyarm/sd-fuse_s5pc110.git
cd sd-fuse_s5pc110
wget http://112.124.9.243/dvdfiles/S5PC110/images/friendlycore-images.tgz
tar xzf friendlycore-images.tgz

./build-kernel.sh friendlycore
./build-uboot.sh friendlycore

# re-pack sd img
sudo ./mk-sd-image.sh friendlycore
```
### Generate an img for SD boot
```
git clone https://github.com/friendlyarm/sd-fuse_s5pc110.git
cd sd-fuse_s5pc110
wget http://112.124.9.243/dvdfiles/S5PC110/images/friendlycore-images.tgz
tar xzf friendlycore-images.tgz

sed -i 's/^Action/#Action/g' friendlycore/boot/images/FriendlyARM.ini

# re-pack sd img
sudo ./mk-sd-image.sh friendlycore
```
