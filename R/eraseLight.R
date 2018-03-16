#' Manually erase non-solar light sources using mouse
#'
#' Click on the bottom-left and top-right corners of a box bounding the light you wish to erase
#' This function is slow, please be patient.
#' @param obs the data frame containing at minimum Date and Light data
#' @param zlim the dynamic range of the plot
#' @param offset an offset in hours used to centre night within the plot y-axis
#' @param threshold ambient light threshold at which twilight is assumed to occur
#' @export
#' @importFrom BAStag lightImage
#' @importFrom BAStag tsimageLocator
#' @return data frame with edited Light data

eraseLight <- function(obs, zlim = c(0, 64), offset = 0, threshold = 5){
  ts <- thresholdPlot(obs, offset = offset, threshold = threshold)
  light.pol <- tsimageLocator(ts, n=2)
  lp.index <- .bincode(light.pol, sort(obs$Date), right = T)
  for(i in lp.index[1]:lp.index[2]){
    if(strftime(obs$Date[i], "%H:%M:%S", tz = "GMT") >= strftime(light.pol[1], "%H:%M:%S", tz = "GMT") &
       strftime(obs$Date[i], "%H:%M:%S", tz = "GMT") <= strftime(light.pol[2], "%H:%M:%S", tz = "GMT") &
       obs$Date[i] >=light.pol[1] &
       obs$Date[i] <= light.pol[2]){
      obs$Light[i] <- 0
    }
  }
  thresholdPlot(obs, offset = offset, threshold = threshold)
  return(obs)
}
