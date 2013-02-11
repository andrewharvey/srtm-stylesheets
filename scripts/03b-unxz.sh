#!/bin/sh

mkdir -p SRTM3
for f in SRTM3-XZ/*.hgt.xz ; do
    b=`basename $f .xz`
    echo "$b"
    xz --keep --decompress --stdout "$f" > "SRTM3/$b"
done
