#' Find max light observations over a coarse time grid then interpolate at finer grid
#' @export
#' @return see help(max_light_delta) for relevant details
interpolate_max_light <- function(d, depth1 = FALSE, depth2 = FALSE, period1 = "30 minutes", period2 = "4 minutes"){
  if(depth1){
    b <- max_light(d[d$Depth < depth1,], period1)
  } else {
    b <- max_light(d, period1)
  }

  fn <- splinefun(b$Date, b$Light, method = "periodic")  # build spline function on max_light

  if(depth2){
    b <- max_light(d[d$Depth < depth2,],  period2)
  } else {
    b <- max_light(d, period2)
  }

  b$Light <- fn(b$Date)      # interpolate on finer scale
  b$Light[1] <- b$Light0[1]  # correct the interpolated first observation
  b$Light[b$Light0 > b$Light] = b$Light0[b$Light0 > b$Light]  # correct under-interpolated observations
  b$Light[b$Light > quantile(b$Light0, 0.99)] = quantile(b$Light0, 0.99)  # correct over-interpolated observations

  b$delta <- c(0, b$Light[2:nrow(b)] - b$Light[1:(nrow(b)-1)])# calculate delta-Light for latent class models
  return(b)
}
