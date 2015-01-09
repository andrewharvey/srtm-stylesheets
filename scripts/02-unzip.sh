#!/bin/sh

for f in dds.cr.usgs.gov/srtm/version2_1/SRTM3/*/*.zip ; do
    unzip -u -d SRTM3 "$f"
done

for f in SRTM1_ZIP/*.zip ; do
    unzip -u -d SRTM1 "$f"
done
