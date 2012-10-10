# About
This package contains a set of shell scripts for working with NASA SRTM
DEM data, gdaldem based stylesheets for creating shaded relief maps,
Mapnik stylesheets for making contours maps, and TileStache configuration
for sandwich the shaded relief and contour maps.

![SRTM3 Hillshaded, Color Relief Contour Map](//andrewharvey4.files.wordpress.com/2012/10/srtm3-1.png)

The aim of the project is to produce a free and open source repeatable workflow
for visualising worldwide elevation data.

While usable on its own, it was also designed to be a base style which could be
built upon to create other maps with more features like place names, roads,
rivers etc.

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

    wget, unzip, xz-utils, gdal-bin, postgresql-client, postgis, carto, tilestache,
    libmapnik | libmapnik2, fonts-sil-gentium-basic

## Downloading SRTM data

    ./scripts/01-download.sh [SRTM3_Region]

To determine the SRTM3_Region see the [region map](http://dds.cr.usgs.gov/srtm/version2_1/Documentation/Continent_def.gif),
in combination with the [actual directory names](http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/) for these regions.

## Unzipping
To unzip these downloads run,

    ./scripts/02-unzip.sh

If you want to keep these files for later reference, you may wish to
re-compress using xz to save space using,

    ./scripts/03-rexz.sh

## Grunt work
If you have made it this far then all the data is prepared and ready for
the real grunt work. The are two bits of processing we do. Preparing the
vector contours and preparing the raster DEM. To create the final
sandwiched map you will need to perform both steps, if not then you can
just perform one.

### Processing the raster DEM

#### Creating a mosaic DEM
To avoid edge artefacts and to make the process simpler, we mosaic all
those 1 x 1 degree tiles into a single continent mosaic using,

    ./scripts/04-merge.sh [SRTM3_Continent] lon0 lon1 lat0 lat1

The last four parameters are the bounds we will use for the mosaic. You
can only use integer values as they are simply used to select which
individual .hgt tiles to glue together.

#### Hill shading and color relief (hypsometric tints)

    ./scripts/07-shaded-relief.sh [SRTM3_Continent]

Keep in mind that the hypsometric tint values are defined in
`stylesheets/color-ramps/srtm3-Continent-color-ramp.gdaldem.txt`. In the first
column you have the elevation value in meters. I've only created a color ramp
specifically suited for the highest point in Australia. I'm not sure of the
best approach for applying this on a global scale.

### Loading the contours
You will need a PostgreSQL database set up somewhere with the PostGIS
extensions installed.

Then make sure you set your [PG* environment variables](http://www.postgresql.org/docs/current/static/libpq-envars.html)
(especially PGDATABASE which is required), then run,

    ./scripts/05-contour-tiles.sh [SRTM3_Continent] lon0 lon1 lat0 lat1

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

There is a [live preview of this sandwiched stylesheet](http://tianjara.net/map#srtm3/8/-34.003/151.125).
