#' Remove days from data where no locations could be estimated from fitted TwilightFree object
#'
#' @param d data frame with Light, Date, Day_num, and state columns at minimum
#' @param return.model logical indicating whether to return predictive model or not
#' @param model a previously fitted predictive model
#' @param threshold numeric Light intensity at twilight
#' @export
#' @return data frame with predicted night and day states in `state` column
eraseMoon <- function(d, return.model = FALSE , model = NULL, threshold = 0){
  d$hms <- lubridate::hour(lubridate::ymd_hms(d$Date))*60 + lubridate::minute(lubridate::ymd_hms(d$Date))
  N <- floor(0.6*max(nrow(d)))
  keep <- sample(1:nrow(d), N, replace = FALSE)
  if(is.null(model)){
    model <- e1071::svm(factor(state) ~ hms + Light, d[keep,])
  }
  d$state <- predict(model, d)
  d$Light[d$state == "night"] <- threshold-1
  if(return.model){
    return(list(x = d, model = model))
  }
  return(d)
}
