## TwilightFree method of geolocation

A new method of geolocation using GLS tag (ambient light) data. TwilightFree has no explicit dependence on being able to estimate or identify the time of twilight, making it very robust to noise (sensor shading or obscuration) in the light data. It uses SST, plausible movement, land/sea masks, and fixes at known locations to improve position estimates.

Please cite:
Bindoff, A., Wotherspoon, S., Guinet, C., & Hindell, M. (in-press) "Twilight free geolocation from noisy light data", *Methods in Ecology & Evolution*

Known bugs:  the default track using `trip(fit, type = "full")` returns the maximum *a posteori* estimate (MAP estimate) for each day. If possible locations straddle the equator, sometimes the MAP estimate for a particularly day is obviously in the wrong hemisphere (the algorithm picks a mathematically plausible but ecologically implausible solution). Calling `essieRaster(fit)` and finding the MAP estimate for the appropriate hemisphere is a useful solution, but a simpler solution is currently in development.
