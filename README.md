# About
This package contains a set of shell scripts for working with NASA SRTM DEM
data, gdaldem based stylesheets for creating shaded relief and/or hypsometric
tinted maps, Mapnik stylesheets for making contours maps and a TileStache
configuration for sandwiching or compositing the shaded relief and contour maps.

![SRTM3 Hillshaded, Color Relief Contour
Map](http://tianjara.net/hosted/srtm3-stylesheet-git-preview.png)

The aim of the project is to produce a free and open source repeatable workflow
for visualising worldwide elevation data.

This project should be useful if you want to,
* automate the download of SRTM3 data
* produce a void filled single large GeoTIFF DEM from SRTM3 HGT tiles
* produce hill shaded, slope shaded, hypsometric and/or contour maps
* have contours loaded into a PostgreSQL/PostGIS database for use in a GIS
* have a simple general purpose elevation layer/map (default style included)

All of the above use cases are accommodated for in these scripts.

# License
With the exception of stylesheets/configure.py which is 3-clause BSD
licensed, all files within this repository are licensed by the author,
Andrew Harvey<andrew.harvey4@gmail.com> as follows.

    To the extent possible under law, the person who associated CC0
    with this work has waived all copyright and related or neighboring
    rights to this work.
    http://creativecommons.org/publicdomain/zero/1.0/

The SRTM data which these scripts are designed to use is in the public
domain because it was solely created by NASA. NASA copyright policy
states that "NASA material is not protected by copyright unless noted".

# Running through the scripts
## Dependencies
To run through all the steps provided by these script you will need,

    wget unzip xz-utils gdal-bin postgresql-client postgis carto tilestache libmapnik|libmapnik2 fonts-sil-gentium-basic python-gdal

## Downloading SRTM data

    ./scripts/01-download.sh SRTM3_Region...

To determine the SRTM3_Region see the [region map](http://dds.cr.usgs.gov/srtm/version2_1/Documentation/Continent_def.gif),
in combination with the [actual directory names](http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/) for these regions.

You can list multiple regions as arguments or just one.

The coordinates refer to the bottom left corner of the tile, or expressed
differently the tile is in the top right quadrant referred to by the coordinate.

## Unzipping downloads
To unzip these downloads run,

    ./scripts/02-unzip.sh

If you want to keep these files for later reference, you may wish to
re-compress using xz to save space using,

    ./scripts/03-rexz.sh

Which you can later uncompress again using,

    ./scripts/03b-unxz.sh

## Grunt work
If you have made it this far then all the data is prepared and ready for
the real grunt work. The are two bits of processing we do. Preparing the
vector contours and preparing the raster DEM. To create the final
sandwiched map you will need to perform both steps, if not then you can
just perform one.

### Raster DEM processing

#### Creating a mosaic DEM
To avoid edge artefacts and to make the process simpler, we mosaic all
those 1 x 1 degree tiles into a single continent mosaic using,

    ./scripts/04-merge.sh SRTM3_Continent lon0 lon1 lat0 lat1

The last four parameters are the bounds we will use for the mosaic. You
can only use integer values as they are simply used to select which
individual .hgt tiles to glue together.

An additional processing step is also run as part of this script to fill the
voids in the data. However you need to apply this patch
http://trac.osgeo.org/gdal/ticket/4464 to your gdal_fillnodata.py script for
this to work.

#### Hill shading and color relief (hypsometric tints)

    ./scripts/07-shaded-relief.sh SRTM3_Continent

Keep in mind that the hypsometric tint values are defined in
`stylesheets/color-ramps/srtm3-Continent-color-ramp.gdaldem.txt`. In the first
column you have the elevation value in meters. I've only created a color ramp
specifically suited for the highest point in Australia. I'm not sure of the
best approach for applying this on a global scale.

### Vector contour processing
You will need a PostgreSQL database set up somewhere with the PostGIS
extensions installed.

Then make sure you set your [PG* environment variables](http://www.postgresql.org/docs/current/static/libpq-envars.html), for example,

    export PGDATABASE=srtm

then run,

    ./scripts/05-contour-tiles.sh lon0 lon1 lat0 lat1

This will convert the DEM into contours and load them into a PostgreSQL
database.

After this you will need to run,

    psql -f ./scripts/06-contour-level-pyramid.sql

This creates materialised tables of higher level contours (ie. 50m from
the base 10m ones) and some other plumbing work.

# Previewing the Mapnik style
If you have made it this far then you should be ready to start rending
some maps!

There are two styles within the stylesheets directory. One for contours
and one for the hill shaded color relief.

There is also a sample TileStache configuration for sandwiching these
together into a single map layer.

The hill shaded color relief style should be ready to go.

The contour style needs to be configured with,

    ./stylesheets/configure.py

You can pass it paramaters --host, --port, --dbname, --user, --password.

When you run it, it will copy the `contours.template.mml` into
`contours.mml` and fill in the new file with your configuration.

You can then further run,

    carto stylesheets/contours.mml > contours.xml

To convert it into a Mapnik XML stylesheet.

You could preview these independently with TileLite's `litserv`, or you
could just run,

    tilestache-server -c stylesheets/srtm3.tilestache.cfg

Alternatively you can generate some samples/previews of both the independent
layers and the sandwiched layer using,

    ./scripts/08-create-previews.sh

Be aware that for this you will need
https://gist.github.com/andrewharvey/1290744 in your $PATH and the ImageMagick
program convert.

There is a [live preview of this sandwiched stylesheet](http://tianjara.net/map#srtm3/8/-34.003/151.125).

# Cleaning up
There are some files you can remove to save some space.

    # remove the original zipped hgt files we downloaded from USGS
    rm -rf dds.cr.usgs.gov

    # remove the unzipped hgt files (if you want you can keep a .tar.xz)
    rm -rf SRTM3

    # if you no longer need the single large DEM but are just using the layers/
    rm -rf SRTM3*.tiff
