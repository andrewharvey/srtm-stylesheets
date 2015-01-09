#!/bin/bash

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/


# argument list of hgt files
files=""

# where the HGT files are at
base=$1

continent=$2

if [ -z $continent ] ; then
  echo "Usage: $0 SRTM1|SRTM3 SRTM3_Region"
  exit 1
fi


# filename of output single merged file
merged=${base}_${continent}.tiff
filled=${base}_${continent}_filled.tiff

if [ -z $6 ] ; then
  echo "Usage: $0 SRTM1|SRTM3 SRTM3_Continent lon0 lon1 lat0 lat1"
  exit 1
else
  lon0=$3
  lon1=$4
  lat0=$5
  lat1=$6
fi

if [ $lat0 -gt $lat1 ] ; then
  echo "lat0 must be <= lat1"
  exit 1
fi
if [ $lon0 -gt $lon1 ] ; then
  echo "lon0 must be <= lon1"
  exit 1
fi

# count how mange files we are planning to merge
counter=0
for lon in `seq $lon0 $lon1` ; do
  if [ $lon -lt 0 ] ; then
      ew='W'
      lon=${lon#-} # remove sign
  else
      ew='E'
  fi
  for lat in `seq $lat0 $lat1` ; do
    if [ $lat -lt 0 ] ; then
        ns='S'
        lat=${lat#-} # remove sign
    else
        ns='N'
    fi
    if [ $base == "SRTM1" ] ; then
        file="${ns}${lat}_${ew}${lon}_1arc_v3.bil"
        file=`echo $file | tr 'A-Z' 'a-z'`
        file="${base}/${file}"
    elif [ $base == "SRTM3" ] ; then
        file="${base}/${ns}${lat}${ew}${lon}.hgt"
    else
        echo "Usage: $0 SRTM1|SRTM3 [SRTM3_Region]"
        echo "Argument 1 must be either SRTM1 or SRTM3"
        exit 1
    fi
    echo "$file"
    if [ -e "$file" ] ; then
      files="${files} $file"
      counter=$(($counter + 1))
    fi
  done
done

echo "Merging $counter files..."

rm -rf $merged
nice gdal_merge.py -o $merged -co BIGTIFF=YES -co COMPRESS=LZW $files

echo "Written $merged"


# check we have the patched gdal_fillnodata.py script
cat `which gdal_fillnodata.py` | grep "\-srcnodata value" > /dev/null
if [ $? -eq 0 ] ; then
    echo "Removing voids..."
    nice gdal_fillnodata.py -srcnodata -32768 $merged -of GTiff -co COMPRESS=LZW -co BIGTIFF=YES $filled

    # just keep the one void filled variant
    rm -rf $merged
    mv $filled $merged
else
    echo "It does not appear that you have the patch at
http://trac.osgeo.org/gdal/ticket/4464 applied. Hence any voids in
SRTM3 data weren't filled."
fi
