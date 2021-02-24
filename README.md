## TwilightFree method of geolocation

A new method of geolocation using GLS tag (ambient light) data. TwilightFree has no explicit dependence on being able to estimate or identify the time of twilight, making it very robust to noise (sensor shading or obscuration) in the light data. It uses SST, plausible movement, land/sea masks, and fixes at known locations to improve position estimates.

Please cite (and read in full):
Bindoff AD, Wotherspoon SJ, Guinet C, Hindell MA. Twilight-free geolocation from noisy light data. *Methods Ecol Evol.* 2017;00:1–9. https://doi.org/10.1111/2041-210X.12953  

Known issues:  
- the default track using `trip(fit, type = "full")` returns the maximum *a posteori* estimate (MAP estimate) for each day. If possible locations straddle the equator, sometimes the MAP estimate for a particularly day is obviously in the wrong hemisphere (the algorithm picks a mathematically plausible but ecologically implausible solution). Calling `essieRaster(fit)` and finding the MAP estimate for the appropriate hemisphere is a useful solution.  
- if a location cannot be determined on one or more days, `trip` will identify which days are affected and print a warning. `SGAT::essie` will also throw warnings as a subtle hint that something went wrong. It is possible that the entire track is unreliable, and efforts should be made to identify the problem (check the grid, use `thresholdPlot` to find non-solar light observations, check the threshold etc)  
- it is **essential** that non-solar light sources are dealt with prior to estimating locations. This is the "Achille's heel" of the `TWilightFree` method. Always check using the `thresholdPlot` function, and adjust thresholds or remove non-solar observations using `eraseLight`. Non-solar light sources may include unusually bright moons, city, ship, car, lighthouse, or factory lights.  

Please use the Issues tab of this git repo to search and report issues or difficulties. This method cannot estimate the impossible, but it rarely fails completely.  


### Installation:  

`# install.packages("devtools")`  
`# install.packages("raster", repos = "https://cran.csiro.au/")`  
`devtools::install_github("SWotherspoon/SGAT")`  
`devtools::install_github("SWotherspoon/BAStag")`  
`devtools::install_github("ABindoff/TwilightFree")`  



Linux users (tested Ubuntu 17.10 Artful) may also need to install the following (from a terminal) in order to install `devtools` and `ncdf4` package:  
sudo apt-get install libssl-dev  
sudo apt-get install libcurl4-openssl-dev  

sudo apt-get install netcdf-bin  
sudo apt-get install libnetcdf-dev  
sudo apt-get install udunits-bin  
sudo apt-get install libudunits2-dev  

