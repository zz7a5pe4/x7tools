#!/bin/bash -e

if [ ! $# = 1 ];then
    echo "need parameter, new iso path"
    exit 1
fi

if [ -f $1 ];then
    while true; do
        read -p "$1 already exist, replace old one, [y]es or [n]o?" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo "exit without any changes" && exit 0;;
            * ) echo "Please answer y or n.";;
        esac
    done
fi

ROOTDIR=`pwd`
ISOCOPYPATH=$ROOTDIR/tmpcd_copied

sudo mksquashfs squashfs-root/ $ISOCOPYPATH/casper/filesystem.squashfs  -noappend

sudo mkisofs -V "X7_Ubuntu LiveCD" -r -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$1"  $ISOCOPYPATH

echo "iso is created successfully"

