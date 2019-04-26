
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cartomisc

<!-- badges: start -->

<!-- badges: end -->

The goal of cartomisc is to …

## Installation

You can install the dev version on Github

``` r
# install.packages("remotes")
remotes::install_github("statnmap/cartomisc")
```

# Usage

``` r
library(dplyr)
library(raster)
library(cartomisc)
library(ggplot2)
```

## Extract part of the data with `gplot_data`

To draw multiple raster on the same ggplot2, or to draw raster after
other objects (points, polygons, lines)

  - data are extracted as a tibble
  - data can then be added to a ggplot2 with `geom_tile`

<!-- end list -->

``` r
# Read some data
slogo <- stack(system.file("external/rlogo.grd", package = "raster")) 
slogo
#> class       : RasterStack 
#> dimensions  : 77, 101, 7777, 3  (nrow, ncol, ncell, nlayers)
#> resolution  : 1, 1  (x, y)
#> extent      : 0, 101, 0, 77  (xmin, xmax, ymin, ymax)
#> coord. ref. : +proj=merc +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 
#> names       : red, green, blue 
#> min values  :   0,     0,    0 
#> max values  : 255,   255,  255

# Get partial raster data to plot in ggplot
r.gg <- gplot_data(slogo)

# Remove NA to reduce size of table
r.gg.nona <- r.gg %>% 
  filter(!is.na(value))

r.gg.nona
#> # A tibble: 23,331 x 4
#>        x     y value variable
#>    <dbl> <dbl> <dbl> <fct>   
#>  1   0.5  76.5   255 red     
#>  2   1.5  76.5   255 red     
#>  3   2.5  76.5   255 red     
#>  4   3.5  76.5   255 red     
#>  5   4.5  76.5   255 red     
#>  6   5.5  76.5   255 red     
#>  7   6.5  76.5   255 red     
#>  8   7.5  76.5   255 red     
#>  9   8.5  76.5   255 red     
#> 10   9.5  76.5   255 red     
#> # … with 23,321 more rows
```

### Plot with ggplot2

``` r
# Plot
ggplot(r.gg.nona) +
  geom_tile(aes(x = x, y = y, fill = value)) +
  scale_fill_gradient("Probability", low = 'yellow', high = 'blue') +
  facet_wrap(vars(variable)) +
  coord_equal()
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

## Sun position

Calculate sun position for hillShade

``` r
sun_position <- sun_position(2019, 04, 26,
  hour = 12, min = 0, sec = 0,
  lat = 46.5, long = 6.5
)
sun_position
#> $elevation
#> [1] 56.48539
#> 
#> $azimuth
#> [1] 192.4585
```

Use with hillShade

``` r
r <- raster(system.file("external/rlogo.grd", package = "raster"))
# slope and aspect
r_slope <- terrain(r, opt = "slope")
r_aspect <- terrain(r, opt = "aspect")
# hillshade
r_hillshade <- hillShade(r_slope, r_aspect, angle = sun_position$elevation, direction = sun_position$azimuth)
# plot
image(r)
image(r_hillshade, col = grey(seq(0, 1, 0.1), alpha = 0.5), add = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
