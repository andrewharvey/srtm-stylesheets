/* 
 * SRTM3 Contours Stylesheet
 *
 * Not usually used on its own. Best combined with a shaded relief of the DEM.
 *
 * Author: Andrew Harvey <andrew.harvey4@gmail.com>
 * License: CC0 http://creativecommons.org/publicdomain/zero/1.0/
 * To the extent possible under law, the person who associated CC0
 * with this work has waived all copyright and related or neighboring
 * rights to this work.
 */


/*
      =====  Protips for generating cartographic contour maps  =====

  Protip #1
    Only use two levels of line thickness at once. So use normal
    thin lines for each contour line and then thicker ones every so
    often. But don't then do even thicker ones even more ofter than that.

  Protip #2
    Your thicker contour lines should either be 5 or 10 times the
    interval of the thin contour lines. So this would produce a thick
    contour line for every 5 or 10 thin contour lines.

  With these two rules in mind creating a contour map is easy. You have
  two paramaters.

    x - the vertical distance between the thin contour lines; x contours
    m - every mth contour line is a thick one; mx contours
  
  We shall call these x*m contour maps.
*/

/* Also keep in mind that with labels on you will need to use a small map
   buffer to avoid the labels being cut on tile boundaries. */


/* default variables */
@contour_line_color: black;

@thin_line_width: 0.2;
@thick_line_width: 0.4;


/* high zooms - 10m*5 */

  /* thin line */
  #contour-10m[zoom >= 11] {
    line-color: @contour_line_color;
    line-width: @thin_line_width;
  }

  /* thick */
  #contour-50m[zoom >= 11] {
    line-color: @contour_line_color;
    line-width: @thick_line_width;
  }

  /* elevation labels */
  /* I'm not sure if these should be off by default though.
     Are they generally usefull, or just cause clutter? */
  #contour-50m[zoom >= 13] {
    text-name: "[ele]";
    text-face-name: "Gentium Regular";
    text-fill: white;
    text-placement: line;
    text-halo-fill: black;
    text-halo-radius: 1.5;
    text-spacing: 400;
    text-min-path-length: 200;

    text-size: 12;
  }

/* medium zooms - 50m*5 */

  /* thin */
  #contour-50m[zoom <= 10][zoom >= 9] {
    line-color: @contour_line_color;
    line-width: @thin_line_width;
  }

  /* thick */
  #contour-250m[zoom <= 10][zoom >= 9] {
    line-color: @contour_line_color;
    line-width: @thick_line_width;
  }

/* low zooms 250m */
  /* thin */
  #contour-250m[zoom <= 8][zoom >= 7] {
    line-color: @contour_line_color;
    line-width: @thin_line_width;
  }

/* no contour lines for zoom 6 or less */
