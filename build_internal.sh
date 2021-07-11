#!/bin/sh
# Build script for s6-overlay with processor architecture detection
apkArch=`apk --print-arch`
if [ $apkArch = "x86_64" ] 
then
    apkArch="amd64"
fi
wget https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-$apkArch-installer -P /tmp
chmod +x /tmp/s6-overlay-$apkArch-installer && /tmp/s6-overlay-$apkArch-installer / 
rm /tmp/s6-overlay-$apkArch-installer