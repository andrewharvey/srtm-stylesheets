#!/bin/sh

mkdir -p SRTM3-XZ
for f in SRTM3/*.hgt ; do
    b=`basename $f`
    xz < "$f" > "SRTM3-XZ/$b.xz"
done
