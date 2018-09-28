#' Find zenith angles from assumed threshold and locations
#'
#' @param d data frame with Light, Date columns at minimum
#' @export
#' @return numeric zenith angle
findZenith <- function(d, day, lon, lat, offset = 0, threshold = 5){
  if (is.null(d$Light) |
      is.null(d$Date)) {
    warning("\nNon-conforming data frame, must have `Date` and `Light` columns. ", immediate. = TRUE)
    return()
  }
  day <- day + offset*60*60
  single.day <- subset(d, d$Date >= as.POSIXct(day, tz = "GMT") & d$Date < as.POSIXct(day+24*60*60, tz = "GMT"))

  zs <- data.frame(SGAT::zenithSimulate(single.day$Date,
                                        lon = rep(lon, length(single.day$Date)),
                                        lat = rep(lat, length(single.day$Date)),
                                        single.day$Date),
                   Light = single.day$Light,
                   state = single.day$state,
                   threshold = threshold)
  return(round(min(zs$Zenith[zs$Light <= zs$threshold], na.rm = TRUE),1))

}
