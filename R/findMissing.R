#' Find days where no locations could be estimated from fitted TwilightFree object
#'
#' @param fit a fitted model returned by SGAT::Essie
#' @param type forward, backward or full posterior (defaults to "full")
#' @export
#' @importFrom SGAT essieMode
#' @return vector of Day_num
findMissing <- function(fit, type = "full"){
  time <- essieMode(fit)$time
  x <- essieMode(fit, type = type)$x
  z <- unlist(lapply(fit$lattice, function(x) length(which.max(x$ps)) != 0))  ## find inestimable locations
  time <- time[z]  ## removes missing days because z == F when max(x$ps) could not be calculated
  if(any(!z)){
    return(which(!z))
  }
return(NULL)
}
