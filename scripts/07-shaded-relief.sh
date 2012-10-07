#!/bin/sh

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# This process follows http://mapbox.com/tilemill/docs/guides/terrain-data/

continent=$1

if [ -z $continent ] ; then
  echo "Usage: $0 [SRTM3_Region]"
  exit 1
fi

if [ ! -e stylesheets/color-ramps/srtm3-${continent}-color-ramp.gdaldem.txt ] ; then
  echo "Could not find stylesheets/color-ramps/srtm3-${continent}-color-ramp.gdaldem.txt"
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
gdalwarp -t_srs "EPSG:900913" -r near -of VRT SRTM3_$continent.tiff SRTM3_$continent-WebMercator.vrt

mkdir -p layers

# make the color relief image
nice gdaldem color-relief SRTM3_$continent-WebMercator.vrt stylesheets/color-ramps/srtm3-${continent}-color-ramp.gdaldem.txt layers/SRTM3_${continent}_color_relief.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# make the hillshaded greyscale image
nice gdaldem hillshade SRTM3_$continent-WebMercator.vrt layers/SRTM3_${continent}_hillshade.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# generate slope for the slopeshade
nice gdaldem slope SRTM3_$continent-WebMercator.vrt layers/SRTM3_${continent}_slope.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# generate the slopeshade
nice gdaldem color-relief layers/SRTM3_${continent}_slope.tiff stylesheets/color-ramps/slope-ramp.txt layers/SRTM3_${continent}_slopeshade.tiff -of GTiff -co COMPRESS=DEFLATE -co ZLEVEL=9

# we only needed this to generate the slopeshade, so remove it now
rm -f layers/SRTM3_${continent}_slope.tiff

# add a link to the layers within the stylesheets directory for the mapnik stylesheet
ln -s -T ../layers stylesheets/layers
