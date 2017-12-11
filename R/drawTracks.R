#' Plot tracks with map
#' @param trip a trip object returned from `trip()`
#' @param gps optional data.frame of reference data with `Lon` and `Lat` columns in time order
#' @param col line colour for trip
#' @param gps.col line colour for gps
#' @param point.cols optional gradient colours for points, NULL if points not required
#' @param main optional title
#' @param pacific TRUE if map uses Pacific-centred co-ordinates
#' @export
#' @import maptools
#' @import polyclip
#' @import raster
drawTracks <- function(gls,
                       gps = NULL,
                       col = "firebrick",
                       gps.col = "dodgerblue",
                       point.cols = c("red","springgreen","royalblue"),
                       main = "",
                       pacific = F){
  xlm <- range(c(gls$Lon, gps$Lon))
  ylm <- range(c(gls$Lat, gps$Lat))
  data(wrld_simpl, package = "maptools", envir = environment())

  if(pacific){
    wrld_simpl <- nowrapRecenter(wrld_simpl, avoidGEOS = TRUE)}
  plot(wrld_simpl,xlim=xlm,ylim=ylm,
            col="grey90",border="grey80", main = main, axes = T)
  xlm <- par()$usr[1:2]
  ylm <- par()$usr[3:4]
  border <- cbind(c(xlm[1], xlm[2], xlm[2], xlm[1], xlm[1]),
                  c(ylm[1], ylm[1], ylm[2], ylm[2], ylm[1]))
  lines(border, col = "black")

  if(!is.null(point.cols)){
    colfunc <- colorRampPalette(point.cols)
    points(cbind(jitter(gls$Lon), jitter(gls$Lat)), col = colfunc(nrow(trip)))}

  if(!is.null(gps)){
    lines(cbind(gps$Lon, gps$Lat), col = gps.col)}

  lines(cbind(gls$Lon, gls$Lat), col = col)

}
