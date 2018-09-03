#' Find a light threshold using calibration position and date
#' @param df data.frame containing `Light` and `Date` data at minimum
#' @param day POSIXct date-time object in GMT or UTC specifying one day of calibration data
#' @param lon known longitude of tag during calibration
#' @param lat known latitude of tag during calibration
#' @param zenith assumed solar zenith angle in degrees at twilight (depends on latitude and time of year, defaults to 96 degrees)
#' @param offset time in hours to offset start of day time, defaults to 0
#' @param verbose will plot light traces if TRUE
#' @export
#' @importFrom SGAT zenithSimulate
#' @return threshold value for TwilightFree model
calibrate <- function(df, day, lon, lat, zenith = 96, offset = 0, verbose = T){
  if(max(df$Light, na.rm = TRUE) > 64){
    print("It looks like your data may not be in BAS tag format. You may need to transform before determining a threshold.")
  }
  day <- day + offset*60*60
  single.day <- subset(df, df$Date >= as.POSIXct(day, tz = "GMT") & df$Date < as.POSIXct(day+24*60*60, tz = "GMT"))

  d.sim <- zenithSimulate(single.day$Date,
                          lon = rep(lon, length(single.day$Date)),
                          lat = rep(lat, length(single.day$Date)),
                          single.day$Date)
  d.sim$Light <- ifelse(d.sim$Zenith < zenith, max(single.day$Light, na.rm = T), 1)
  thresh <- max(single.day$Light[which(d.sim$Zenith >= zenith)])

  if(verbose){
    plot(single.day$Date,
         single.day$Light,
         col = "red",type = "l",
         lwd = 2,
         ylim = c(0,max(single.day$Light, na.rm = T)),
         xlab = day, main = cbind(lon, lat))
    lines(d.sim$Date, d.sim$Light, lwd = 2)
    abline(h = thresh, lty = 2)
    print(paste0("max light in night window: ", thresh, " assuming a solar zenith angle of: ", zenith))
  }

  return(thresh)

}


