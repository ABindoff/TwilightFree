#' Find days where animal was likely to have returned to colony
#'
#' Where Light observations for a day are mostly below threshold (dark)
#' the animal is likely to have returned to a colony, nest, or burrow.
#'
#' @param obs a data frame containing at minimum Date and Light data
#' @param threshold numeric threshold for Light at twilights
#' @param colony vector with Lon and Lat coordinates for colony
#' @param q proportion of Light observations below threshold (between [0, 1])
#' @export
#' @importFrom lubridate floor_date
#' @importFrom dplyr group_by summarise `%>%`
#' @return data frame of dates and location to use in `fixd` argument of `TwilightFree`
findColony <- function(obs, threshold, colony, q = 0.9){
  if(is.null(obs$Date)){
    warning("\nData frame requires Date column\n")
    return()
  }
  if(is.null(obs$Day_num)){
    obs$Day_num <- numberDays(obs)
  }
  if(q > 1 | q < 0){
    warning("\nq must be between 0 and 1, setting q to 0.99\n")
    q <- 0.99
  }
  k <- dplyr::group_by(obs, Day_num) %>%
    dplyr::summarise(q = quantile(Light, q) < threshold)
  k <- as.character(unique(floor_date(obs$Date[obs$Day_num %in% k$Day_num[k$q]], "1 days")))
  nest <- data.frame(Date = k,
                     Lon = colony[1],
                     Lat = colony[2],
                     stringsAsFactors = FALSE)
  return(nest)
}
