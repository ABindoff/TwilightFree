#' Remove days from data where no locations could be estimated from fitted TwilightFree object
#'
#' @param x data frame with Light, Date, and Day_num columns at minimum
#' @param fit a fitted model returned by SGAT::Essie
#' @export
#' @return data frame with inestimable days removed
removeMissing <- function(x, fit){
  k <- findMissing(fit)
  `%nin%` <- Negate(`%in%`)
  x <- x[x$Day_num %nin% k,]
  x
}
