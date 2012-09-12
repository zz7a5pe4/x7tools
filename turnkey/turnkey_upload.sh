#!/bin/bash -e
set -x

KERNEL=""
RAMDISK=""
DISK_FORMAT=""
CONTAINER_FORMAT=""


if [ ! $# = 1 ];then
    echo "need package path"
    exit -1
fi 
xdir="$1"
IMAGE_NAME=`echo $1 | cut -d"-"  -f 2`
#echo $IMAGE_NAME
#exit 0
ADMIN_USER=admin
ADMIN_TENANT=admin
ADMIN_PASSWORD=admin
HOST_IP=127.0.0.1

TOKEN=`curl -s -d  "{\"auth\":{\"passwordCredentials\": {\"username\": \"$ADMIN_USER\", \"password\": \"$ADMIN_PASSWORD\"}, \"tenantName\": \"$ADMIN_TENANT\"}}" -H "Content-type: application/json" http://$HOST_IP:5000/v2.0/tokens | python -c "import sys; import json; tok = json.loads(sys.stdin.read()); print tok['access']['token']['id'];"`

#echo $TOKEN

#IMAGE_FNAME=$1

#rm -Rf "$xdir";
#mkdir "$xdir"
#tar -zxf $IMAGE_FNAME -C "$xdir"
KERNEL=$(for f in "$xdir/"*-kernel* "$xdir/"aki-*/image; do
         [ -f "$f" ] && echo "$f" && break; done; true)
RAMDISK=$(for f in "$xdir/"*-initrd* "$xdir/"ari-*/image; do
         [ -f "$f" ] && echo "$f" && break; done; true)
IMAGE=$(for f in "$xdir/"*.img "$xdir/"ami-*/image; do
         [ -f "$f" ] && echo "$f" && break; done; true)

echo $KERNEL $RAMDISK $IMAGE

if [[ -z "$IMAGE_NAME" ]]; then
    IMAGE_NAME="gitlab"
fi

KERNEL_ID=""; RAMDISK_ID="";
if [ -n "$KERNEL" ]; then
    RVAL=`glance add --silent-upload -A $TOKEN name="$IMAGE_NAME-kernel" is_public=true container_format=aki disk_format=aki < "$KERNEL"`
    KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`
fi
if [ -n "$RAMDISK" ]; then
    RVAL=`glance add --silent-upload -A $TOKEN name="$IMAGE_NAME-ramdisk" is_public=true container_format=ari disk_format=ari < "$RAMDISK"`
    RAMDISK_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`
fi
glance add -A $TOKEN name="${IMAGE_NAME%.img}" is_public=true container_format=ami disk_format=ami ${KERNEL_ID:+kernel_id=$KERNEL_ID} ${RAMDISK_ID:+ramdisk_id=$RAMDISK_ID} < <(zcat --force "${IMAGE}")

