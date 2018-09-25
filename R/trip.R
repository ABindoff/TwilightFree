#' Convert SGAT::essie fit object to matrix of `Date`, `Lon`, `Lat` columns
#' @param fit SGAT::essie fit object
#' @param type "full" posterior, "forward" or "backward" probabilities to diagnose convergence of fit
#' @export
#' @importFrom SGAT essieMode
#' @return matrix with columns named `Date`, `Lon`, `Lat`
trip <- function(fit, type = c("full", "forward", "backward")){
  time <- essieMode(fit)$time
  x <- essieMode(fit, type = type)$x
  z <- unlist(lapply(fit$lattice, function(x) length(which.max(x$ps)) != 0))  ## find inestimable locations
  time <- time[z]  ## removes missing days because z == F when max(x$ps) could not be calculated
    trip <- data.frame(Date = time, Lon = x[,1], Lat = x[,2])
      if(any(!z)){
        warning("\nDay ", list(which(!z)), " missing, could not estimate location.\n\n", immediate. = T)
        }
  return(trip)
}
