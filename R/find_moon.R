require(dplyr)
find_moon <- function(d, n = 6, q = 0.25, full = TRUE){
  if (is.null(d$Light) |
      is.null(d$Day_num)) {
    warning("\nNon-conforming data frame, must have `Day_num` and `Light` columns. ", immediate. = TRUE)
    return(-1)
  }
  dir = 1
  if(full){
    dir = -1
  }
  h <- group_by(d, Day_num) %>%
    summarise(ml = quantile(Light, q),
              dn = round(median(Day_num), 0)) %>%
    arrange(dir*ml)
  return(h$dn[1:n])
}
