% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/max_light_delta.R
\name{max_light_delta}
\alias{max_light_delta}
\title{Find max light in period and smooth light observations}
\usage{
max_light_delta(d, depth = FALSE, period = "6 minutes",
  smooth.delta = 6, smooth.light = 3)
}
\arguments{
\item{d}{data frame with Light, Date columns at minimum}

\item{depth}{discard observations below this dive depth}

\item{period}{character string, find max Light in the period}

\item{smooth.delta}{observations to smooth first derivative over}

\item{smooth.light}{observations to smooth Light over}
}
\value{
data frame with smoothed Light and `delta` column of derivatives
}
\description{
Find max light in period and smooth light observations
}
