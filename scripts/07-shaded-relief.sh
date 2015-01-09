#!/bin/sh

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# This process follows http://mapbox.com/tilemill/docs/guides/terrain-data/

base=$1
continent=$2

if [ -z $continent ] ; then
  echo "Usage: $0 SRTM1|SRTM3 [SRTM3_Region]"
  exit 1
fi

base_lower=`echo "$base" | tr 'A-Z' 'a-z'`

if [ ! -e stylesheets/color-ramps/srtm-${continent}-color-ramp.gdaldem.txt ] ; then
  echo "Could not find stylesheets/color-ramps/srtm-${continent}-color-ramp.gdaldem.txt"
  echo ""
  echo "This file defines the color ramp used for the relief image of the DEM."
  echo ""
  echo "This is not a global color ramp, if it were Mount Everest would look good"
  echo "but a flat country would not."
  echo ""
  echo "If you are just rendering a single country then you may want to rescale"
  echo "the ramp for a user defined maximum elevation."
  exit 1
fi

# reproject to slippy map projection
gdalwarp -t_srs "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs" -r near -of VRT ${base}_$continent.tiff ${base}_$continent-WebMercator.vrt

mkdir -p layers

# make the color relief image
nice gdaldem color-relief ${base}_$continent-WebMercator.vrt stylesheets/color-ramps/srtm-${continent}-color-ramp.gdaldem.txt layers/${base}_${continent}_color_relief.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# make the hillshaded greyscale image
nice gdaldem hillshade ${base}_$continent-WebMercator.vrt layers/${base}_${continent}_hillshade.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# generate slope for the slopeshade
nice gdaldem slope ${base}_$continent-WebMercator.vrt layers/${base}_${continent}_slope.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# generate the slopeshade
nice gdaldem color-relief layers/${base}_${continent}_slope.tiff stylesheets/color-ramps/slope-ramp.txt layers/${base}_${continent}_slopeshade.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# we only needed this to generate the slopeshade, so remove it now
rm -f layers/${base}_${continent}_slope.tiff

# add a link to the layers within the stylesheets directory for the mapnik stylesheet
ln -s -T ../layers stylesheets/layers
