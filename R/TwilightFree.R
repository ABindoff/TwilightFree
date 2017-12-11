require(SGAT)
require(raster)
#' Specify a model for forwards-backwards estimation
#'
#' @param df data.frame containing `Light`, `Date`, and optionally `Temp` data
#' @param alpha hyperparameters for the noise (shading) assumption
#' @param beta hyperparameters for the movement assumption
#' @param dt optional parameter specifying the number of seconds in a segment (day)
#' @param threshold tag-specific value for luminance at twilight (obtained by calibration)
#' @param zenith solar zenith angle at twilight
#' @param deployed.at deployment location c(lon, lat) for first day of observation
#' @param retrieved.at retrieval location c(lon, lat) for last day of observation
#' @param fixd optional data.frame of fixed (known) locations containing `Date`, `Lon`, `Lat` (will overwrite deployed.at and retrieved.at locations if != NULL)
#' @param sst raster of SST data from NOAA OI SST
#' @export
#' @return a TwilightFree model object which can be fitted using SGAT::essie()
TwilightFree <- function(df,
                         alpha = c(1, 1/10),
                         beta = c(1, 1/4),
                         dt = NULL,
                         threshold = 5,
                         zenith = 96,
                         deployed.at = F,
                         retrieved.at = F,
                         fixd = NULL,
                         sst = NULL){
  # Define segment by date
  seg <- floor((as.numeric(df$Date)- as.numeric(min(df$Date)))/(24*60*60))
  # Split into `slices`
  slices <- split(df,seg)
  slices <- slices[-c(1,length(slices))]


  # find min date in each slice
  dmin <- c()
  for (i in 1:length(slices[])) {
    dmin[i] <- min(slices[[i]]$Date)
  }

  dmin <-  strptime(as.POSIXct(dmin, "GMT", origin = "1970-01-01"),
                    "%Y-%m-%d",
                    "GMT")

  ## sst raster from ncdf file at
  #  https://www.esrl.noaa.gov/psd/repository/
  #  (NOAA OI SST -> Weekly and Monthly -> sst.wkmean.*)
  indices <- NA
  if(!is.null(sst)){
    indices <<- .bincode(as.POSIXct(dmin), as.POSIXct(strptime(getZ(sst), "%Y-%m-%d", "GMT"), "GMT"),
                         right = FALSE)
  }


  # fixed locations, if retrieved.at and deployed.at are supplied it these will be used unless fixd != NULL
  x0 <- matrix(0, length(slices), 2)
  x0[1,] <- deployed.at
  x0[length(slices),] <- retrieved.at
  fixed <- rep_len(c(as.logical(deployed.at[1L]),
                     logical(length(slices)-2),
                     as.logical(retrieved.at[1L])),
                   length.out = length(slices))

  # if a data.frame containing `Date` in %Y-%m-%d format, `Lon` and `Lat` is supplied these will be utilised here
  if(!is.null(fixd)) {
    slice_date <- lapply(slices, function(x) min(x$Date))
    slice_date <- as.vector(unlist(lapply(slice_date, function(x)
      as.character(strptime(x, format = "%Y-%m-%d")))))
    indx <- which(slice_date %in% fixd$Date)
    locs <- matrix(0, length(slices), 3)
    for (i in seq_along(indx)) {
      locs[indx[i], ] <- c(fixd$Lon[i], fixd$Lat[i], 1)
    }
    x0 <- locs[, 1:2]
    fixed <- as.logical(locs[, 3])
  }


  ## Times (hours) between observations
  time <- .POSIXct(sapply(slices,
                          function(d) mean(d$Date)), "GMT")
  if (is.null(dt))
    dt <- diff(as.numeric(time) / 3600)


  ## Contribution to log posterior from each x location
  logpk <- function(k, x) {
    n <- nrow(x)
    logl <- double(n)

    ss <- solar(slices[[k]]$Date)
    obsDay <- (slices[[k]]$Light) >= threshold

    ## Loop over location
    for (i in seq_len(n)) {
      ## Compute for each x the time series of zeniths
      expDay <- zenith(ss, x[i, 1], x[i, 2]) <= zenith

      ## comparison to the observed light -> is L=0 (ie logl=-Inf)
      if (any(obsDay & !expDay)) {
        logl[i] <- -Inf
      } else {
        count <- sum(expDay & !obsDay)
        logl[i] <- dgamma(count, alpha[1], alpha[2], log = TRUE)
      }
    }
    ## Return sum of likelihood + prior
    logl + logp0(k, x, slices)
  }

  ## Behavioural (movement) contribution to the log posterior
  logbk <- function(k, x1, x2) {
    spd <- pmax.int(gcDist(x1, x2), 1e-06) / dt[k]
    dgamma(spd, beta[1L], beta[2L], log = TRUE)
  }
  list(
    logpk = logpk,
    logbk = logbk,
    fixed = fixed,
    x0 = x0,
    time = time,
    alpha = alpha,
    beta = beta,
    sst = sst
  )
}


#' calculate SST component of log-posterior in TwilightFree model
logp0 <- function(k, x, slices) {
  x[, 1] <- x[, 1] %% 360
  tt <- median(slices[[k]]$Temp, na.rm = TRUE)
  if (is.na(tt)) {
    0
  } else {
    dnorm(tt, extract(sst[[indices[k]]], x), 2, log = T)
  }
}
