#!/bin/sh

if [ -z $1 ] ; then
  echo "Usage: $0 [SRTM3_Region]..."
  exit 1
fi

for ARG in $* ; do
    wget --mirror --no-parent http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/$ARG/
done
