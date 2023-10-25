#!/bin/bash
function mnt() {
echo "MOUNTING"
sudo mount -t proc /proc ${2}proc
sudo mount -t sysfs /sys ${2}sys
sudo mount -o bind /dev ${2}dev
sudo mount -o bind /run ${2}run
sudo mount --bind / ${2}host
sudo chroot ${2}
}
function umnt() {
echo "UNMOUNTING"
sudo umount ${2}proc
sudo umount ${2}sys
sudo umount ${2}dev
sudo umount ${2}run
sudo umount ${2}host
}
if [ "$1" == "-m" ] && [ -n "$2" ] ;then
mnt $1 $2
elif [ "$1" == "-u" ] && [ -n "$2" ];then
umnt $1 $2
else
echo ""
echo "Either 1'st, 2'nd or both parameters were missing"
echo ""
echo "1'st parameter can be one of these: -m(mount) OR -u(umount)"
echo "2'nd parameter is the full path of rootfs directory(with trailing '/')"
echo ""
echo "For example: ./chmount.sh -m /media/sdcard/"
echo ""
fi