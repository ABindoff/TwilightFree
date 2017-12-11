#' Make a grid for TwilightFree model incorporating land or sea mask
#'
#' @param lon extents of longitude
#' @param lat extents of latitude
#' @param cell.size size of grid cells in degrees, defaults to 1
#' @param mask set mask for areas animals are assumed to be restricted to, "sea", "land", or "none"
#' @param pacific optional Pacific-centred map, defaults to Atlantic-centred map
#' @export
#' @import maptools
#' @import polyclip
#' @import raster
#' @import sp
#' @return raster object giving the locations the animal may have visited
makeGrid <- function(lon = c(-180, 180), lat = c(-90, 90), cell.size = 1, mask = "sea", pacific = FALSE) {
  data(wrld_simpl, package = "maptools", envir = environment())
  if(pacific){
    wrld_simpl <- nowrapRecenter(wrld_simpl, avoidGEOS = TRUE)}
  nrows <- abs(lat[2L] - lat[1L]) / cell.size
  ncols <- abs(lon[2L] - lon[1L]) / cell.size
  grid <- raster(
    nrows = nrows,
    ncols = ncols,
    xmn = min(lon),
    xmx = max(lon),
    ymn = min(lat),
    ymx = max(lat),
    crs = proj4string(wrld_simpl)
  )
  grid <- rasterize(wrld_simpl, grid, 1, silent = TRUE)
  grid <- is.na(grid)
  switch(mask,
         sea = {},
         land = {
           grid <- subs(grid, data.frame(c(0,1), c(1,0)))},
         none = {
           grid <- subs(grid, data.frame(c(0,1), c(1,1)))
         }
  )
  return(grid)
}
