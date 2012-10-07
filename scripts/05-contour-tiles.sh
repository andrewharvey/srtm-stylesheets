#!/bin/bash

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# where the HGT files are at
base="SRTM3"

mkdir -p SRTM3_Contour_Tiles/

interval=10

if [ -z $4 ] ; then
  echo "Usage: $0 lon0 lon1 lat0 lat1"
  exit 1
else
  e0=$1
  e1=$2
  n0=$3
  n1=$4
fi

psql -c "DROP TABLE IF EXISTS srtm3;"

for e in `seq $e0 $e1` ; do
  for n in `seq $n0 $n1` ; do
    f="${base}/S${n}E${e}.hgt"
    if [ -e "$f" ] ; then
      b=`basename $f .hgt`
      echo $b

      # create contours for this hgt file then save it as a shape file
      nice ionice -c 3 \
          gdal_contour \
            -i $interval \
            -a ele \
            -snodata -32768 \
            "$f" \
            SRTM3_Contour_Tiles/$b.shp

      # then load that shape file into PostgreSQL
      nice ionice -c 3 \
          ogr2ogr \
            -f PostgreSQL \
            -nln srtm3 \
            -append \
            -t_srs 'EPSG:900913' \
            PG:dbname=$PGDATABASE \
            "SRTM3_Contour_Tiles/$b.shp"

      # we don't need the shape file anymore
      rm -f SRTM3_Contour_Tiles/$b.*
    fi
  done
done

rm -rf SRTM3_Contour_Tiles

psql -c "ALTER TABLE srtm3 DROP COLUMN id;"
