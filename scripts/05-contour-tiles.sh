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
  lon0=$1
  lon1=$2
  lat0=$3
  lat1=$4
fi

if [ $lat0 -gt $lat1 ] ; then
  echo "lat0 must be <= lat1"
  exit 1
fi
if [ $lon0 -gt $lon1 ] ; then
  echo "lon0 must be <= lon1"
  exit 1
fi

psql -c "DROP TABLE IF EXISTS srtm3;"

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
    f="${base}/${ns}${lat}${ew}${lon}.hgt"
    if [ -e "$f" ] ; then
      counter=$(($counter + 1))
      b=`basename $f .hgt`
      echo $b

      working_tile="$f"
      # check we have the patched gdal_fillnodata.py script
      cat `which gdal_fillnodata.py` | grep "\-srcnodata value" > /dev/null
      if [ $? -eq 0 ] ; then
        echo "Removing voids."
        filled_tile=`mktemp --suffix=.tiff`
        gdal_fillnodata.py -srcnodata -32768 "$f" -of GTiff "$filled_tile"
        working_tile="$filled_tile"
      fi

      # create contours for this hgt file then save it as a shape file
      nice ionice -c 3 \
          gdal_contour \
            -i $interval \
            -a ele \
            -snodata -32768 \
            "$working_tile" \
            SRTM3_Contour_Tiles/$b.shp

      # remove the tile if it is a temporary one we just created
      if [ ! -z "${filled_tile+xxx}" -a -e ${filled_tile} ]; then
        # VAR $filled_tile is SET AND file exists
        rm -f "$filled_tile"
      fi

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

if [ $counter -eq 0 ] ; then
    echo "No suitable SRTM3 tiles were found in ${base}/ for the bounds you specified."
else
    echo "Imported contours for $counter SRTM3 tiles."
fi

rm -rf SRTM3_Contour_Tiles

psql -c "ALTER TABLE srtm3 DROP COLUMN id;"
