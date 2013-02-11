#!/bin/bash

# This script is licensed CC0 by Andrew Harvey <andrew.harvey4@gmail.com>
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# This script will create some sample/preview images of the final stylesheet.

# You must have the mapnik_render_static_map.py script from
# https://gist.github.com/andrewharvey/1290744 in your $PATH

preview=preview/
mkdir -p $preview

preview_width=1400
preview_height=800

function render {
  x=$1
  y=$2
  z=$3
  w=$4
  h=$5
  output=$6

  echo -n "Rendering $output"
  mapnik_render_static_map.py \
      --mapfile stylesheets/srtm3-hillshaded-color-relief.xml \
      --centrex $x \
      --centrey $y \
      --zoom $z \
      --width $w \
      --height $h \
      --output ${preview}${output}_base.png \
      > /dev/null

  echo -n "."

  mapnik_render_static_map.py \
      --mapfile stylesheets/contours.xml \
      --centrex $x \
      --centrey $y \
      --zoom $z \
      --width $w \
      --height $h \
      --output ${preview}${output}_contour.png \
      > /dev/null

  echo -n "."

  convert ${preview}${output}_base.png ${preview}${output}_contour.png \
      -composite -format png ${preview}${output}.png

  echo " saved as ${preview}${output}.png"
}

#       centrex   centrey  z width hight name
render 149.41818 -35.66511 9 $preview_width $preview_height z9
render 150.85859 -34.40224 12 $preview_width $preview_height z12
render 150.77019 -34.05095 10 $preview_width $preview_height z10
render 146.71692 -42.66931 9 $preview_width $preview_height z9_tas
render 150.28988 -35.28192 12 $preview_width $preview_height z12_mnp
render 151.01601 -33.26194 11 $preview_width $preview_height z11_nth
