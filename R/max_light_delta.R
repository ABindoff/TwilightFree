#' Find max light in period and smooth light observations
#'
#' @param d data frame with Light, Date columns at minimum
#' @param depth discard observations below this dive depth
#' @param period character string, find max Light in the period
#' @param smooth.delta observations to smooth first derivative over
#' @param smooth.light observations to smooth Light over
#' @export
#' @importFrom lubridate floor_date
#' @importFrom dplyr filter
#' @return data frame with smoothed Light and `delta` column of derivatives
max_light_delta <- function(d,
                            depth = FALSE,
                            period = "6 minutes",
                            smooth.delta = 6,
                            smooth.light = 3){
  if (is.null(d$Light) |
      is.null(d$Date)) {
    warning("\nNon-conforming data frame, must have `Date` and `Light` columns. ", immediate. = TRUE)
    return(d)
  }
  if(depth){
    d <- dplyr::filter(d, Depth < depth)
  }
  d <- mutate(d, m = lubridate::floor_date(Date, period)) %>%
    group_by(m) %>%
    mutate(Light0 = Light,
           Light = max(Light, na.rm = TRUE)) %>%
    filter(Light == Light0) %>%
    ungroup() %>%
    dplyr::select(-m)
  d$Light <- ma(d$Light, smooth.light)
  d$Light[is.na(d$Light)] = 0
  d$delta <- c(0,diff(d$Light)/as.numeric(diff(d$Date))) # calculate delta-Light for latent class models
  d$delta <- ma(d$delta, smooth.delta)
  d$delta[is.na(d$delta)] = 0
  return(d)
}

ma <- function(x, k){
  stats::filter(x, rep(1/k,k))
}
