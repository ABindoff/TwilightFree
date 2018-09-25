#' Remove days from data where no locations could be estimated from fitted TwilightFree object
#'
#' @param d data frame with Light, Date, Day_num, and state columns at minimum
#' @param return.model logical indicating whether to return predictive model or not
#' @param model a previously fitted predictive model
#' @param q number between 0 and 1 which controls sensitivity
#' @export
#' @importFrom lubridate hour ymd_hms
#' @return data frame with predicted night and day states in `state` column
eraseMoon <- function(d, return.model = FALSE , model = NULL, q = .25){
  d$hms <- hour(ymd_hms(d$Date))*60 + minute(ymd_hms(d$Date))
  N <- floor(0.5*max(d$Day_num, na.rm = TRUE))
  keep <- find_moon(b, N, q = q, full = FALSE)  # train on moonless nights
  if(is.null(model)){
    model <- e1071::svm(factor(state) ~ hms + Light, d[d$Day_num %in% keep,])
  }
  d$state <- predict(model, d)
  d$Light[d$state == "night"] <- 0
  if(return.model){
    return(list(x = d, model = model))
  }
  return(d)
}
