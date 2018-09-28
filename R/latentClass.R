#' Fit latent class mixture model to quickly classify day and night states
#'
#' @param d data frame with Light, Date, delta columns at minimum
#' @export
#' @import mclust
#' @importFrom magrittr %>%
#' @return data frame with predicted day and night states in `state` column
latentClass <- function(d, nstates = 3L, verbose = TRUE){
  if(is.null(d$delta)){
    warning("\n\nMissing column `delta`, see help(latent_class) \n")
    return(d)
  }
  d$sqLight <- d$Light^2
  state <- try(mclust::Mclust(d[, c("sqLight", "delta")], G = nstates))

  d$state <- state$classification
  d$conf <- 1-state$uncertainty

  if(verbose){
    plot(delta ~ Light, d, col = factor(state), cex = 0.2)
  }

  top <- dplyr::group_by(d, state) %>%
    dplyr::summarise(m = median(Light)) %>%
    dplyr::arrange(m)
  d$state[d$state == top$state[1]] = "night"
  d$state[d$state == "night" & d$conf < 0.5] = "day"
  d$state[d$state != "night"] = "day"

  return(d)

}
