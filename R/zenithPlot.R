#' Plot simulated twilights from Lon, Lat and estimated zenith
#'
#' @param x data frame with Light, Date columns at minimum
#' @param gps data frame with Date, Lon, Lat columns at minimum
#' @param zenith solar zenith angle estimated from data
#' @param threshold numeric Light intensity at twilight
#' @export
#' @return plot of thresholded Light data with simulated zeniths highlighted
zenithPlot <- function (x, gps, threshold = 0, zenith = 95, offset = 0){
  zs <- SGAT::zenithSimulate(gps$Date, gps$Lon, gps$Lat, x$Date)
  zs$Light <- zs$Zenith < zenith
  x$y = 0
  x$y[x$Light >= threshold] = 0.7
  x$y[zs$Light] = x$y[zs$Light] + 0.3
  x$Light <- x$y

  lightImage(x, offset = offset, zlim = c(0, 1), col = viridis(40))
}
