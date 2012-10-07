#!/bin/sh

continent=Australia

./scripts/01-download.sh $continent && \
./scripts/02-unzip.sh && \
./scripts/04-merge.sh $continent 140 153 25 37 && \
./scripts/05-contour-tiles.sh 140 153 25 37 && \
psql -f scripts/06-contour-level-pyramid.sql && \
./scripts/07-shaded-relief.sh $continent
