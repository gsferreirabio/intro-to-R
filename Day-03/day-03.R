################################################################################
# Day 03: Analysing fossil occurrences data

# Data derived from the Paleobiology Database https://paleobiodb.org/

# Let's use the package paleobioDB
## https://docs.ropensci.org/paleobioDB/index.html

install.packages("paleobioDB")
library(paleobioDB)

?pbdb_occurrences()  ## this function will download data from the PBDB
# look at the link to search for the variables we can download
testudines <- pbdb_occurrences(base_name = "Testudines",
                               interval = "Cenozoic",
                               show = c("coords", "classext", "paleoloc"),
                               limit = "all", 
                               vocab = "pbdb")  ## vocab makes better names

dim(testudines)  ## 5731 occurrences
head(testudines, 3)  ## let's look at the head of the dataframe
# max_ma & min_ma are the range in millions of years (annum)
# lng & lat are geographic coordinates
class(testudines)

?pbdb_map  ## Map fossil records
pbdb_map(data = testudines)


# let's change the colors of the plots and the scale of occurrences
install.packages("viridisLite")
library(viridisLite)

testudines.map = pbdb_map(data = testudines,
                          col_int = "grey80",
                          pch = 16,
                          col_ocean = "lightblue",
                          col_point = viridis(5))

testudines.map

# This will map the richness of the occurrences using a raster (grid)
pbdb_map_richness(data = testudines, 
                  rank = "genus",
                  res = 5,
                  col_int = "grey80",
                  col_ocean = "lightblue",
                  col_rich = viridis(10),
                  title = "Genus richness")

# and we can plot by different ranks
pbdb_map_richness(data = testudines, 
                  rank = "species",
                  res = 5,
                  col_int = "grey80",
                  col_ocean = "lightblue",
                  col_rich = viridis(10),
                  title = "Species richness")

pbdb_map_richness(data = testudines, 
                  rank = "family",
                  res = 5,
                  col_int = "grey80",
                  col_ocean = "lightblue",
                  col_rich = viridis(10),
                  title = "Family richness")

# and also change the resolution of the raster grid
pbdb_map_richness(data = testudines, 
                  rank = "genus",
                  res = 2,
                  col_int = "grey80",
                  col_ocean = "lightblue",
                  col_rich = viridis(10),
                  title = "Genus richness")

##############################################
## How to plot a specific region? did not work
pbdb_map_richness(data = testudines, 
                  rank = "family",
                  res = 2,
                  col_int = "grey80",
                  col_ocean = "lightblue",
                  col_rich = viridis(10), 
                  regions = c("Brazil", "Chile", "Argentina", "Paraguay", 
                              "Uruguay", "Bolivia", "Peru", "Ecuador", "Colombia",
                              "Venezuela","Guyana", "Suriname", "French Guiana"))

##############################################
# Other nice features of the paleobioDB package

# Temporal range of taxa
pbdb_temp_range(testudines,
                rank = "family")

pbdb_temp_range(testudines,
                rank = "genus",
                col = "#0055AA")

# Richness through time
pbdb_richness(testudines, 
              rank = "species", 
              ylab = "Number of Species")


# define the temporal extent of the plot, default = 0:10
pbdb_richness(testudines, 
              rank = "species", 
              ylab = "Number of Species", 
              temporal_extent = c(0, 23))

# change the resolution, default = 1
pbdb_richness(testudines, 
              rank = "genus", 
              ylab = "Number of Species", 
              res = 0.5)  ## looks more detailed

pbdb_richness(testudines, 
              rank = "genus", 
              ylab = "Number of Species", 
              res = 0.1)  ## maybe too much

# and change the color
pbdb_richness(testudines, 
              rank = "genus", 
              ylab = "Number of Species", 
              res = 0.5,
              col = "#A0A00F30",
              bord = "#A0A00F")  ## looks more detailed



# Patterns of origination and extinction
pbdb_orig_ext(testudines,
              rank = "genus",
              temporal_extent = c(0, 66))

# change the resolution
pbdb_orig_ext(testudines,
              rank = "genus",
              temporal_extent = c(0, 66),
              orig_ext = 1,  ## this argument defines whether origination
              res = 2)

pbdb_orig_ext(testudines,
              rank = "genus",
              temporal_extent = c(0, 66),
              orig_ext = 2,  ## or extinction
              res = 2)



################################################################################
# Data analysis with Palaeoverse

# Let's download directly from github
install.packages("devtools")  ## devtools allows us to download from ext. source
devtools::install_github("palaeoverse/palaeoverse")
library(palaeoverse)

# Generate time bins
dev.off()  ## clear plot window

?time_bins()
time_bins(interval = "Cenozoic")
time_bins(interval = "Cenozoic", plot = TRUE)

# we can also save it to an object
bins <- time_bins(interval = c("Mesozoic", "Cenozoic"), plot = TRUE)

# then we can assign the fossil occurrences to those time bins
?bin_time

# the occurrences dataframe already contains this info
head(testudines)

#but with bin_time we can use different methods
testudines.binned <- bin_time(occdf = testudines, 
                              bins = bins,
                              method = "majority")
class(testudines.binned)

# Calculate and plot temporal range of fossil taxa by genus
?tax_range_time
tax_range_time(testudines, 
               name = "genus",
               plot = TRUE)
# some NAs

# remove NAs
testudines.nNAs <- subset(testudines, !is.na(genus))

tax_range_time(testudines.nNAs, 
               name = "genus",
               plot = TRUE)

# and now by family
testudines.nNAs <- subset(testudines, !is.na(family))
tax_range_time(testudines.nNAs, 
               name = "family",
               plot = TRUE,
               plot_args = list(ylab = "Families",
                                pch = 15,
                                col = "grey30",
                                lty = 2))


# Generate palaeocoordinates based on actual coordinates
?palaeorotate  
# again, the palaeocoordinates are contained in the original occurrences 
## dataframe (if selected), but with this function you can use different models
## and methods for rotating them

testudines.palaeocoord <- palaeorotate(testudines.binned, age = "bin_midpoint")  
## this uses an internet external connection and might not be available

names(testudines.palaeocoord)  ## rot_model, p_lng, p_lat

# the look_up function will convert the interval values derived from the pbdb
## dataframe into official numeric ages based on the intervals of the 
## International Comission on Stratigraphy (ICS). This is useful for 
## standardizing data from different sources.

# It will also calculate the midpoint of the temporal range for each occurrence
?look_up
testudines.palaeocoord <- look_up(testudines.palaeocoord, 
                                  early_interval = "early_interval", 
                                  late_interval = "late_interval", 
                                  int_key = interval_key)

# we can now plot those occurrences per time bin and per paleo_lat, for example
plot(x = testudines.palaeocoord$interval_mid_ma,
     y = testudines.palaeocoord$p_lat,
     xlab = "Time (Ma)",
     ylab = "Palaeolatitude (\u00B0)",
     xlim = c(66, 0), 
     xaxt = "n",
     pch = 20,
     cex = 1.5)

# let's change the points a bit
plot(x = testudines.palaeocoord$interval_mid_ma,
     y = testudines.palaeocoord$p_lat,
     xlab = "Time (Ma)",
     ylab = "Palaeolatitude (\u00B0)",
     xlim = c(66, 0), 
     xaxt = "n",
     pch = 20,
     col = rgb(0, 0, 0, 0.3),
     cex = 1.5)

# Add geological time scale
axis_geo(side = 1, 
         intervals = "epoch")


################################################################################
# Project: color the data points by family
# Plot occurrences per time bin highlighting the fossil record of three families 
## of turtles
# Look at the graph


che.col <- rgb(102, 194, 165, 200, maxColorValue = 255)
pod.col <- rgb(141, 160, 203, 200, maxColorValue = 255)
tri.col <- rgb(252, 141, 98, 200, maxColorValue = 255)

plot(x = testudines.palaeocoord$interval_mid_ma,
     y = testudines.palaeocoord$p_lat,
     xlab = "Time (Ma)",
     ylab = "Palaeolatitude (\u00B0)",
     xlim = c(66, 0), 
     xaxt = "n",
     pch = 20,
     col = rgb(0.8, 0.8, 0.8, 0.1),
     cex = 1.5)
points(x = testudines.palaeocoord$interval_mid_ma[which(testudines.palaeocoord$family == "Trionychidae")],
       y = testudines.palaeocoord$p_lat[which(testudines.palaeocoord$family == "Trionychidae")],
       pch = 20,
       col = tri.col,
       cex = 1.8)
points(x = testudines.palaeocoord$interval_mid_ma[which(testudines.palaeocoord$family == "Chelidae")],
       y = testudines.palaeocoord$p_lat[which(testudines.palaeocoord$family == "Chelidae")],
       pch = 20,
       col = che.col,
       cex = 1.8)
points(x = testudines.palaeocoord$interval_mid_ma[which(testudines.palaeocoord$family == "Podocnemididae")],
       y = testudines.palaeocoord$p_lat[which(testudines.palaeocoord$family == "Podocnemididae")],
       pch = 20,
       col = pod.col,
       cex = 1.8)


axis_geo(side = 1, 
         intervals = "epoch")
legend("topright", 
       legend = c("Chelidae", "Podocnemididae", "Trionychidae"),
       col = c(che.col, pod.col, tri.col),
       bty = "n",
       cex = 0.8,
       pt.cex = 1.8,
       pch = 20)


################################################################################
# Day 07
################################################################################
# Maps in R
# There is a very good online book for those interested in Spatial analyses and
## maps called Spatial Data Science. It is free: https://r-spatial.org/book/
install.packages("terra")
install.packages("geodata")
library(terra)
library(geodata)

# import a world countries map
countries <- world(resolution = 5, path = "maps")
head(countries)
class(countries)

plot(countries)

# import a table with country codes and continents
cntry.codes <- country_codes()
head(cntry.codes)

# add this table to the countries map attributes
?merge
countries <- merge(x = countries, 
                   y = cntry.codes, 
                   by.x = "GID_0", ## this info should be in the other df
                   by.y = "ISO3",  ## that means the GID_0 and ISO3 are the same
                   all.x = TRUE)

head(countries)

# plot the map of countries coloured according to "continent"
plot(x = countries, 
     y = "continent", 
     lwd = 0.2,  ## line width
     main = "Global continents and countries")


# let's ignore the country borders
# dissolve (using aggregate) countries into a continents map
continents <- aggregate(countries, by = "continent")
values(continents)
plot(continents, 
     "continent", 
     lwd = 0.2, 
     main = "Global continents")

# note that each continent is a multi-part polygon including mainland and islands
## for example, let's look at Africa
plot(continents[1,])

# disaggregate continent polygons, to then separate islands and mainlands
?disagg
continents <- disagg(continents)
continents

# get a map of just the continent mainlands (largest polygons)
unique(continents$continent)
largest <- (order(expanse(continents), decreasing = TRUE))[1:length(unique(continents$continent))]
# keep only the largest element from each continent

mainlands <- continents[largest,]  ## combine them in a single object

plot(mainlands, "continent", lwd = 0.2, main = "Continent mainlands")

# now just get a map of just the islands
islands <- erase(continents, mainlands)  ## erase mainlands from continents
plot(islands, "continent", lwd = 0.2, main = "World islands")

# you can then crop and mask a raster map to given islands or continents

################################################################################
# get data from data elevation
?elevation_global
elevation <- elevation_global(res = 10, 
                              path = "maps")  ## resolution can be changed

# let's separate Africa
afr_mainland <- subset(mainlands, 
                       mainlands$continent == "Africa")
# crop the elevation dataset based on afr_mainland
?crop  ## using afr_mainland to mask the elevation object
elev_afr_mainland <- crop(elevation, 
                          afr_mainland, 
                          mask = TRUE)
# and now plot
plot(elev_afr_mainland, 
     main = "Elevation in mainland Africa")

# we can always add a plot to an object
elev_afr_plot <- plot(elev_afr_mainland, 
                      main = "Elevation in mainland Africa")

# you can also use different colors
# function gray()
?gray()
plot(elev_afr_mainland, 
     col = (gray(seq(0.1,0.9,length.out = 100))))
plot(elev_afr_mainland, 
     col = (gray(seq(0.9,0.1,length.out = 100))))
# function map.pal - color palettes for maps
?map.pal()
plot(elev_afr_mainland, 
     col = (map.pal("elevation", n = 100)))
plot(elev_afr_mainland, 
     col = (map.pal("elevation", n = 10)))
plot(elev_afr_mainland, 
     col = (map.pal("haxby", n = 100)))


# you can also compute a buffer around a given continent, and use it to crop
## marine layers to get only the near-shore waters to that continent
afr <- subset(continents, continents$continent == "Africa")
afr_buff <- terra::buffer(afr, width = 200000)  ## 200km
afr_buff <- terra::buffer(afr_mainland, width = 200000)  ## 200km
plot(afr_buff, col = "darkblue", background = "lightblue")
plot(afr_mainland, col = "tan", add = TRUE)


# import a marine variable, e.g., bathymetry
bathy_source <- "https://gebco2023.s3.valeria.science/gebco_2023_land_cog.tif"
bathy <- terra::rast(bathy_source, vsi = TRUE)  ## rasterize it

afr_bathy <- terra::crop(bathy, 
                         afr_buff, 
                         mask = TRUE)
plot(afr_bathy, 
     col = hcl.colors(100, "blues"))
plot(countries, 
     col = "tan", add = TRUE)

plot(afr_bathy, col = hcl.colors(100, "blues"))
plot(elev_afr_mainland, col = (gray(seq(0.9,0.1,length.out = 100))), add = TRUE)

# most importantly, you can plot points on top of these maps
points(x = 0, y = 20, pch = 16, cex = 2, col = "pink")



################################################################################
# Palaeogeographic maps
# gplatesr downloads data from the GPlates Web Service and can reconstruct
## palaeocoordinates
# check here how to download: 
## https://gwsdoc.gplates.org/reconstruction/reconstruct-coastlines

# To download the maps we will use the function st_read
install.packages("sf")
library(sf)

paleocoastlines.url <- "http://gws.gplates.org/reconstruct/coastlines/?time=72&model=GOLONKA"

paleocoastlines <- st_read(paleocoastlines.url)

# check it
plot(paleocoastlines)

# to plot the paleomap we will use ggplot because it has a function geom_sf
library(ggplot2)

ggplot() +
  geom_sf(data = paleocoastlines) +
  labs(title = "Maastrichtian Paleomap") 


# now let's download some data from the Maastrichtian

dinosaurs.maastr <- pbdb_occurrences(base_name = "Dinosauria",
                                     interval = "Maastrichtian",
                                     show = c("coords", "classext", "paleoloc"),
                                     limit = "all", 
                                     vocab = "pbdb",
                                     pgm = "gplates")

dim(dinosaurs.maastr)  ## 4134 occurrences

# now to plot the points using ggplot we include the geom_point() function
ggplot() +
  geom_sf(data = paleocoastlines) +
  labs(title = "Maastrichtian Paleomap") +
  geom_point(data = dinosaurs.maastr,
             aes(x = paleolng, y = paleolat))

# and we can modify the plot, for example
ggplot() +
  geom_sf(data = paleocoastlines, fill = "grey80", color = "black") +
  labs(title = "Maastrichtian Paleomap")+
  theme_minimal() +
  geom_point(data = dinosaurs.maastr,
             aes(x = paleolng, y = paleolat),
             colour = "purple",
             alpha = 0.3,
             show.legend = FALSE)


# we can also use base R to plot
plot(paleocoastlines$geometry)
points(x = dinosaurs.maastr$paleolng, 
       y = dinosaurs.maastr$paleolat, 
       pch = 16, 
       col = "#9a0aff8a")




################################################################################
# Project: Elevation map of the Americas plotting the occurrences of Testudinidae
## TIP: you will need to use the OR operator | when subsetting the map
## the map should include elevation information

# first take the elevation information for the map
elevation <- elevation_global(res = 10, path = "maps")

# then subset the continents map to just Europe and Asia
americas <- subset(continents, 
                   continents$continent == "North America" | continents$continent == "South America")

# crop the elevation data to just Eurasia
elev_americas <- crop(elevation, americas, mask = TRUE)
plot(elev_americas,
     main = "Elevation in Eurasia",
     col = (gray(seq(0.9,0.1,length.out = 100))),
     xlim = c(-175, -20))

plot(countries[which(countries$continent == "North America" | countries$continent == "South America")], 
     add = TRUE)

testudines.colored <- testudines 

names(bins)  ## bins has a column "interval_name" and we need to match it with
## the testudines data

head(testudines)  ## early_interval is what we are looking for

names(testudines.colored)[10] <- "interval_name"  ## let's change that name

# now we merge bins with testudines.colored using the column interval_name
## this will add the color code info for each stage contained in bins to the 
## testudines.colored dataframe
testudines.colored <- merge(testudines.colored, bins, by = "interval_name", all.x = TRUE)

names(testudines.colored)  ## now it has a column "colour" with the color codes

points(testudines$lng[which(testudines$family == "Testudinidae")], 
       testudines$lat[which(testudines$family == "Testudinidae")], 
       pch = 16,
       col = testudines.colored$colour)  ## and here we use the colour column
