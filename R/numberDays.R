#' Number each day in a column named Day_num
#'
#' A small number of TwilightFree helper functions require a `Day_num` column
#' @param obs a data frame containing at minimum Date and Light data
#' @export
#' @return data frame with Day_num column of integers appended
numberDays <- function(obs){
  if(is.null(obs$Date)){
    warning("Data frame requires Date column\n")
    return(obs)
  }
  obs$Day_num <- as.integer((obs$Date - obs$Date[1]) / (24 * 60 * 60))
  return(obs)
}

