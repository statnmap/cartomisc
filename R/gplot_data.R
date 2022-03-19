#' Transform raster as data.frame to be later used with ggplot
#' Modified from rasterVis::gplot
#'
#' @param x A Raster* object
#' @param maxpixels Maximum number of pixels to use
#'
#' @details rasterVis::gplot is nice to plot a raster in a ggplot but
#' if you want to plot different rasters on the same plot, you are stuck.
#' If you want to add other information or transform your raster as a
#' category raster, you can not do it. With `cartomisc::gplot_data`, you retrieve your
#' raster as a data.frame that can be modified as wanted using `dplyr` and
#' then plot in `ggplot` using `geom_tile`.
#' If Raster has levels, they will be joined to the final tibble.
#'
#' @export

gplot_data <- function(x, maxpixels = 50000)  {
  if (class(x) == "SpatRaster"){ # work with terra package rasters
    x <- terra::spatSample(x, maxpixels, as.raster = TRUE)
    coords <- terra::xyFromCell(x, seq_len(terra::ncell(x)))
    ## Extract values
    dat <- utils::stack(as.data.frame(terra::values(x)))
    names(dat) <- c('value', 'variable')
    # If only one variable
    if (dat$variable[1] == "terra::values(x)") {
      dat$variable <- names(x)
    }
    
    dat <- dplyr::as_tibble(data.frame(coords, dat))
    ## OLD `gplot_data` FUNCTION
  }else{ # work with raster package rasters
    x <- raster::sampleRegular(x, maxpixels, asRaster = TRUE)
    coords <- raster::xyFromCell(x, seq_len(raster::ncell(x)))
    ## Extract values
    dat <- utils::stack(as.data.frame(raster::getValues(x)))
    names(dat) <- c('value', 'variable')
    # If only one variable
    if (dat$variable[1] == "raster::getValues(x)") {
      dat$variable <- names(x)
    }
    
    dat <- dplyr::as_tibble(data.frame(coords, dat))
    
    if (!is.null(levels(x))) {
      dat <- dplyr::left_join(dat, levels(x)[[1]],
                              by = c("value" = "ID"))
    }
  }
  dat
}
