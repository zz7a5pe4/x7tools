#!/bin/bash -e

if [ ! $# = 1 ];then
    echo "need parameter, iso path"
    exit 1
fi

if [ ! -f $1 ];then
    echo "$1 not exist"
    exit 2
fi

ROOTDIR=`pwd`
ISOMOUNTPATH=$ROOTDIR/tmpcd
ISOCOPYPATH=$ROOTDIR/tmpcd_copied

[ -d $ISOMOUNTPATH ] || mkdir -p $ISOMOUNTPATH

if [ "$(ls -A $ISOMOUNTPATH)" ];then
    echo "$ISOMOUNTPATH Not Empty, couldn't mount"
    exit 3
fi

sudo mount $1 -o loop,ro $ISOMOUNTPATH

if [ -d $ISOCOPYPATH ];then
    echo "remove old $ISOCOPYPATH content"
    sudo rm -rf $ISOCOPYPATH
fi

cp -rf $ISOMOUNTPATH $ISOCOPYPATH

sudo unsquashfs $ISOCOPYPATH/casper/filesystem.squashfs
sudo umount $ISOMOUNTPATH

echo "extract iso content success to squashfs-root"
