#' Convert SGAT::essie fit object to matrix of `Date`, `Lon`, `Lat` columns
#' @param fit SGAT::essie fit object
#' @param type "full" posterior, "forward" or "backward" probabilities to diagnose convergence of fit
#' @export
#' @importFrom SGAT essieMode
#' @return matrix with columns named `Date`, `Lon`, `Lat`
trip <- function(fit, type = c("full", "forward", "backward")){
  trip <- data.frame(as.POSIXct(strptime(essieMode(fit)$time, "%Y-%m-%d")), essieMode(fit, type = type)$x)
  names(trip) <- c("Date", "Lon", "Lat")
  return(trip)
}
