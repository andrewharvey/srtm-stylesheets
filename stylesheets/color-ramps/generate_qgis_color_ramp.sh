#!/bin/sh

cat srtm3-Australia-color-ramp.gdaldem.txt | \
    tr ' ' ',' | \
    sed 's/$/,255/g' | \
    sed -r 's/([^,]*)(.*)/\1\2,\1m/g' | \
    sed '1i\INTERPOLATION:INTERPOLATED' \
    > srtm3-Australia-color-ramp.qgis.txt
