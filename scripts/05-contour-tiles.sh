#!/bin/bash

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

base=$1
base_lower=`echo "$base" | tr 'A-Z' 'a-z'`

mkdir -p ${base}_Contour_Tiles/

interval=10

if [ -z $5 ] ; then
  echo "Usage: $0 SRTM1|SRTM3 lon0 lon1 lat0 lat1"
  exit 1
else
  lon0=$2
  lon1=$3
  lat0=$4
  lat1=$5
fi

if [ $lat0 -gt $lat1 ] ; then
  echo "lat0 must be <= lat1"
  exit 1
fi
if [ $lon0 -gt $lon1 ] ; then
  echo "lon0 must be <= lon1"
  exit 1
fi

psql -c "DROP TABLE IF EXISTS ${base_lower};"

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
    if [ $base == "SRTM1" ] ; then
        f="${ns}${lat}_${ew}${lon}_1arc_v3.bil"
        f=`echo $f | tr 'A-Z' 'a-z'`
        f="${base}/${f}"
    elif [ $base == "SRTM3" ] ; then
        f="${base}/${ns}${lat}${ew}${lon}.hgt"
    else
        echo "Argument 1 must be either SRTM1 or SRTM3"
        exit 1
    fi
    echo $f
    if [ -e "$f" ] ; then
      counter=$(($counter + 1))
      if [ $base == "SRTM1" ] ; then
         b=`basename $f .bil`
      elif [ $base == "SRTM3" ] ; then
         b=`basename $f .hgt`
      fi
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
            ${base}_Contour_Tiles/$b.shp

      # remove the tile if it is a temporary one we just created
      if [ ! -z "${filled_tile+xxx}" -a -e "${filled_tile}" ]; then
        # VAR $filled_tile is SET AND file exists
        rm -f "$filled_tile"
      fi

      # then load that shape file into PostgreSQL
      nice ionice -c 3 \
          ogr2ogr \
            -f PostgreSQL \
            -nln srtm \
            -append \
            -t_srs "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs" \
            PG:dbname=$PGDATABASE \
            "${base}_Contour_Tiles/$b.shp"

      # we don't need the shape file anymore
      rm -f ${base}_Contour_Tiles/$b.*
    fi
  done
done

if [ $counter -eq 0 ] ; then
    echo "No suitable ${base} tiles were found in ${base}/ for the bounds you specified."
else
    echo "Imported contours for $counter ${base} tiles."
fi

rm -rf ${base}_Contour_Tiles

psql -c "ALTER TABLE srtm DROP COLUMN id;"
