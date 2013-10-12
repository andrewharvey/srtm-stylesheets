#!/bin/bash

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# where the HGT files are at
base="SRTM3"

# argument list of hgt files
files=""

continent=$1

if [ -z $continent ] ; then
  echo "Usage: $0 [SRTM3_Region]"
  exit 1
fi


# filename of output single merged file
merged=SRTM3_${continent}.tiff
filled=SRTM3_${continent}_filled.tiff

if [ -z $5 ] ; then
  echo "Usage: $0 [SRTM3_Continent] lon0 lon1 lat0 lat1"
  exit 1
else
  lon0=$2
  lon1=$3
  lat0=$4
  lat1=$5
fi

# count how mange files we are planning to merge
counter=0
for lon in `seq $lon0 $lon1` ; do
  for lat in `seq $lat0 $lat1` ; do
    if [ $lon -lt 0 ] ; then
        ew='W'
        lon=${lon#-} # remove sign
    else
        ew='E'
    fi
    if [ $lat -lt 0 ] ; then
        ns='S'
        lat=${lat#-} # remove sign
    else
        ns='N'
    fi
    hgt="${base}/${ns}${lat}${ew}${lon}.hgt"
    echo "$hgt"
    if [ -e "$hgt" ] ; then
      files="${files} $hgt"
      counter=$(($counter + 1))
    fi
  done
done

echo "Merging $counter files..."

rm -rf $merged
nice gdal_merge.py -o $merged -co BIGTIFF=YES -co COMPRESS=DEFLATE -co ZLEVEL=9 $files

# check we have the patched gdal_fillnodata.py script
cat `which gdal_fillnodata.py` | grep "\-srcnodata value" > /dev/null
if [ $? -eq 0 ] ; then
    echo "Removing voids..."
    nice gdal_fillnodata.py -srcnodata -32768 $merged $filled

    # just keep the one void filled variant
    rm -rf $merged
    mv $filled $merged
else
    echo "It does not appear that you have the patch at
http://trac.osgeo.org/gdal/ticket/4464 applied. Without it, the voids cannot be
filled."
fi
