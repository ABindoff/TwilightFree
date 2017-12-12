library(SGAT)
library(BAStag)
library(raster)
library(readr)
library(TwilightFree)
library(maptools)

load("tutorials/sst_2014_2017.RData") ## `sst`  download from https://github.com/ABindoff/TwilightFree/blob/master/tutorials/sst_2014_2017.RData

grid <- makeGrid(c(125, 145), c(-45,-30), cell.size = 1/4, mask = "sea", pacific = T)
plot(grid)

# light and temp data are often in separate files
d.lig <- read.csv("https://raw.githubusercontent.com/ABindoff/TwilightFree/master/tutorials/nzfs.lig.csv")
head(d.lig)
# fix Date to %Y-%m-%d %H:%M:%S format
d.lig$Date <- as.POSIXct(strptime(as.character(d.lig$Date), "%d/%m/%Y %H:%M", tz="GMT"))

# read temp data
d.tem <- read.csv("https://raw.githubusercontent.com/ABindoff/TwilightFree/master/tutorials/nzfs.tem.csv")
d.tem$Date <- as.POSIXct(strptime(as.character(d.tem$Date), "%d/%m/%Y %H:%M", tz="GMT"))

# align temp observations with light observations
d.lig$Temp[d.lig$Date %in% d.tem$Date] <- d.tem$Temp[d.tem$Date %in% d.lig$Date]

# check the aligned data and view image
d.lig[c(3456:3460,3500:3504),]
lightImage(d.lig, offset = 5, zlim = c(0, 64))

# chop the calibration and transit periods off the ends
d.lig <- subset(d.lig,Date >= as.POSIXct("2017-01-27 00:00",tz = "GMT") &
                  Date < as.POSIXct("2017-04-21 00:00",tz = "GMT"))
lightImage(d.lig, offset = 5, zlim = c(0,64))

# find optimal threshold and solar zenith angles for tag using `calibrate`
zen <- 96
day <- as.POSIXct("2017-01-28 00:00", "GMT")
thresh <- calibrate(d.lig, day, 137.22, -35.78, zen) *1.01

# dates where animal returned to the colony were recorded in field notes
# and recorded in this spreadsheet (but the Date column needs formatting)
sightings <- data.frame(Date = c("2017-01-28", "2017-02-11", "2017-02-28", "2017-03-15", "2017-03-20", "2017-04-19"),
                        Lon = 137.5,
                        Lat = -36.1)

model <- TwilightFree(d.lig,
                      alpha=c(1, 1/5),
                      beta=c(1, 1/4),
                      zenith = zen, threshold = thresh,
                      fixd = sightings, # these are the colony locations and dates
                      sst = sst) # this is the sst raster stack

# fit the model using the grid from `makeGrid`
fit <- SGAT::essie(model,grid,epsilon1=1.0E-4, epsilon2 = 1E-4)

# plot the result
locs <- trip(fit)
drawTracks(locs, pacific = T)


# smooth using a state space model
#install.packages("bsam")
library(bsam)
locs$Argos_loc_class <- "G"  ## set all to class "G" (trick bsam into thinking it's Argos data)
locs$lonerr <- 1 ##error in deg
locs$laterr <- 1
locs$gmt <- as.POSIXct(paste(as.character(locs$Date), "12:00:00", sep=" "), tz="GMT")
locs$ref <- 1

d <- locs[, c("ref", "gmt", "Argos_loc_class","Lon", "Lat", "lonerr", "laterr")]
colnames(d) <- c("id", "date","lc",  "lon", "lat" , "lonerr", "laterr")


fit <- fit_ssm(d, model = "DCRW", tstep = 1, adapt = 5000, samples = 5000,
               thin = 5, span = 0.2)

# diag_ssm(fit)
# plot_fit(fit)
result <- get_summary(fit)
result$Lon <- result$lon
result$Lat <- result$lat
drawTracks(result, pacific = T)
