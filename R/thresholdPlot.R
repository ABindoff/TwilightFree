#' Plot light record using threshold to identify above-threshold light where we might reasonably expect dark
#' @param threshold the pre-determined threshold of luminance which separates day from night
#' @param x data frame with, at minimum, columns names `Date` and `Light`
#' @param offset an offset in hours used to centre night within the plot y-axis
#' @export
#' @importFrom BAStag lightImage
#' @return plot of thresholded light
thresholdPlot <- function(x, threshold = 5, offset = 0){
   x$y = 0
   x$y[x$Light >= threshold] = 1
   for(i in 3:nrow(x)){
     if(x$y[i] != x$y[i-1]){
       x$y[i-c(1,2)] = 0.5
     }
   }
   x$Light <- x$y
   lightImage(x, offset = offset, zlim = c(0,1), col = c("grey20", "red", "grey90"))
}
