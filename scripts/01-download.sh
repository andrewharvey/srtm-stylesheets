#!/bin/sh

# This script will only download SRTM3 data as SRTM1 data isn't yet available in the same way.

if [ -z $1 ] ; then
  echo "Usage: $0 [SRTM3_Region]..."
  exit 1
fi

for ARG in $* ; do
    wget --mirror --no-parent http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/$ARG/
done
