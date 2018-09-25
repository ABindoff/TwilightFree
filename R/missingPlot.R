#' Remove days from data where no locations could be estimated from fitted TwilightFree object
#'
#' @param x data frame with Light, Date, and Day_num columns at minimum
#' @param fit a fitted model returned by SGAT::Essie
#' @param threshold threshold for twilight
#' @param fixd data frame with Date, Lon, Lat of fixed locations
#' @export
#' @importFrom lubridate floor_date as_date
#' @importFrom BAStag lightImage
#' @importFrom viridisLite viridis
#' @return ts plot
missingPlot <- function(x, fit, threshold = 5, fixd = NULL, offset = 0){
  x$y = 0
  x$y[x$Light >= threshold] = 0.7
  for(i in 3:nrow(x)){
    if(x$y[i] != x$y[i-1]){
      x$y[i-c(1,2)] = 0.4
    }
  }
  x$Light <- x$y
  x$Light[x$Day_num %in% findMissing(fit)] <- x$Light[x$Day_num %in% findMissing(fit)] + 0.2
  if(!is.null(fixd)){
    x$Light[floor_date(as_date(x$Date), "1 days") %in% as_date(fixd$Date)] <- x$Light[floor_date(as_date(x$Date), "1 days") %in% as_date(fixd$Date)] + 0.1
  }
  lightImage(x, offset = offset, zlim = c(0,1), col = viridis(40))
}
