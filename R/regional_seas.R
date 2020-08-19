#' Create buffer divided by closest region
#'
#' @param x Spatial polygon layer
#' @param group Character. The grouping variable for your subareas
#' @param dist distance from coasts of the buffer area. See ?sf::st_buffer
#' @param density density of points along the coastline.
#' (the higher, the more precise the region attribution)
#'
#' @importFrom sf st_buffer st_cast st_difference st_line_sample st_sf st_geometry
#' @importFrom sf st_combine st_voronoi st_intersection st_join st_is_empty `st_geometry<-`
#' @importFrom dplyr summarise mutate distinct group_by_at n
#'
#' @export

regional_seas <- function(x,
                          group,
                          dist = units::set_units(30, km),
                          density = units::set_units(0.1, 1/km)
) {

  # Create a merged region entity
  x_union <- x %>%
    summarise()

  # Create a doughnut for regional seas areas, 30km off coasts
  x_donut <- x_union %>%
    st_buffer(
      dist = dist
    ) %>%
    st_cast() %>%
    # Remove inside terrestrial parts
    st_difference(x_union) %>%
    st_cast()

  # First merge everything and transform as lines
  x_lines <- x_union %>%
    # transform polygons as multi-lines
    st_cast("MULTILINESTRING") %>%
    # transform multi-lines as separate unique lines
    st_cast("LINESTRING")

  # Then as regular points
  x_points <- x_lines %>%
    # transform as points, 0.1 per km (= 1 every 10 km)
    # Choose density according to precision needed
    st_line_sample(density = density) %>%
    st_sf() #%>%
  # remove empty geometry (small islands where sample is not possible with this density)
  # filter(!st_is_empty(geometry))

  if (any(st_is_empty(x_points$geometry))) {
    # Add original islands if empty
    x_lines_multipoints <- x_lines %>%
      st_cast("MULTIPOINT")
    # replace geomtry with original lines as points
    st_geometry(x_points)[st_is_empty(x_points$geometry)] <-
      st_geometry(x_lines_multipoints)[st_is_empty(x_points$geometry)]

    x_points <- x_points %>% st_cast()

    warning("There were empty geometries after sampling points along coastlines. ",
            "'density' was probably not big enough for some isolated polygons. ",
            "They have been reinstated with their original resolution")
  }

  # Create voronoi polygons around points
  x_vd_region_distinct <- x_points %>%
    st_combine() %>%
    st_voronoi() %>%
    st_cast() %>%
    st_intersection(x_donut) %>%
    st_cast() %>%
    st_sf() %>%
    mutate(id_v = 1:n()) %>%
    st_join(x) %>%
    # group_by(id_v) %>%
    # summarise(across(.cols = everything(), .fns = first)) # Not on {sf}
    # summarise_all(.funs = first) # Not on {sf}
    distinct(id_v, .keep_all = TRUE)

  # group by variable
  if (!missing(group)) {
    x_seas <- x_vd_region_distinct %>%
      group_by_at(group) %>%
      summarise()

    return(x_seas)
  }

  return(x_vd_region_distinct)
}
