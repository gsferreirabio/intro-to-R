################################################################################
# Day 2: Data types, data frames, missing values, packages, functions

setwd("d:/R Projects/Intro-to-R/datasets")  ## set your working directory
getwd()  ## check your working directory

# Factors
# Factors are categorical variables that have a fixed number of levels
obj.colors = factor(c("black", "white", "black", "black", "pink", "white"))  ## 
class(obj.colors)
levels(obj.colors)
nlevels(obj.colors)
length(levels(obj.colors))  ## the length of the levels is = nlevels

# Data frames
# A data frame is created when you read a table in R
## check the arguments of read.table()
daphnia.data = read.table(file = "daphnia.txt", header = T)  
daphnia.data
class(daphnia.data)
head(daphnia.data)  ## returns parts of an object, by default the first 6 lines
## this data frame has column (w names): 1 continuous and 3 categorical variables
daphnia.data[,1]
daphnia.data$growthRate
daphnia.data[,1] == daphnia.data$growthRate
daphnia.data[10,1] == daphnia.data$growthRate[10]

# attach is very useful, it will attach a database to the R search path
attach(daphnia.data)
water
detergent
daphnia

# are the categorical variables factors?
is.factor(daphnia.data$detergent)
is.factor(as.factor(detergent)) ## as.factor() will convert a 
## variable to factor

# the change into factor can be made permanent as:
daphnia.data$detergent = as.factor(daphnia.data$detergent) 
is.factor(daphnia.data$detergent)
levels(daphnia.data$detergent)

# factors are treated alphabetically by default
as.factor(daphnia.data$water)
# the second argument in factor() allows you to change the order
factor(as.factor(daphnia.data$water), levels = c("Wear", "Tyne"))
## this might be useful when ordering bars in a bar chart, for example

# you can also turn factor levels into numbers
as.vector(unclass(daphnia.data$detergent))
# This type of treatment is called coercing

# There are many is. functions
lv = c(T, F, T)
is.logical(lv)
is.factor(lv)
fv = as.factor(lv)  ## as.factor() will coerce the object into factors
is.factor(fv)
fv
nv = as.numeric(lv)  ## as.numeric() will coerce the object into numbers
nv

as.numeric(factor(c("a", "b", "c")))
## these is. functions can be very useful in other functions when checking the 
##  type of the input object (see below)


################################################################################
# Missing values (NAs)
y = c(4, NA, 7)
is.na(y)  ## this will check if there are NAs in the vector y
# to produce a vector with the NA striped out, use:
y[!is.na(y)]  ## this reads: "values of y which are not NA

# some functions will not work when there are missing values in the data
x = c(1:8, NA)
mean(x)
mean(x, na.rm = T)  ## mean() has an argument to remove NAs

# it is also possible to replace the NAs using the ifelse() function
ifelse(test = is.na(x), yes = 9, no = x)




################################################################################
# End of session
#To see what variables you have created in this session
objects()



################################################################################
# Installing and using packages
# To use a package you just need to call it using the function library()
library(base)

# to see the contents of a package use:
library(help=base)

# not all packages are readly available on R, some you'll need to install
install.packages("ggplot2")
# and then load it
library(ggplot2)


# Setting the working directory
getwd()
setwd("Path to the directory")

#Another helpful function is to list files in the directory
dir()

################################################################################
# Functions: inspect the help page for a new function

daphnia.data = read.table("daphnia.txt", header = TRUE)
head(daphnia.data)
class(daphnia.data)
dim(daphnia.data)

F24.size = read.table("size-meas.csv", header = TRUE)  ## cannot open
F24.size = read.table("Ferreira_etal-2024/size-meas.csv", header = TRUE)

class(F24.size)
dim(F24.size)  ## there is something wrong, only one line
head(F24.size)

?read.table  ## sep = "" means the separator is space by default
# but there is another function called read.csv whose separator is "," by default
F24.size.csv = read.csv("Ferreira_etal-2024/size-meas.csv", header = TRUE)
identical(F24.size, F24.size.csv)
head(F24.size)
head(F24.size.csv)
dim(F24.size)
dim(F24.size.csv)

# But we can also change the sep argument to get the same result
F24.size = read.table("Ferreira_etal-2024/size-meas.csv", sep = ",", 
                      header = TRUE)

identical(F24.size.csv, F24.size)  ## they are identical

# In the folder Godoy_etal-2019 we have a .xlsx file, how to read it?
read.table("Godoy_etal-2019/G19-dataset.xlsx", header = T)
read.csv("Godoy_etal-2019/G19-dataset.xlsx", header = T)
## open it with notepad and you will see a different structure

# There is also a read_excel() function in another package, can you find it?
# Package readxl
# Install package and 
install.packages("readxl")
library(readxl)

?read_excel()
G19.data = read_excel("Godoy_etal-2019/G19-dataset.xlsx")
head(G19.data)  ## it looks different, let's check why
class(G19.data)  ## it has multiple object types, including "tbl"
G19.data$Species  ## but it works similarly to a dataframe
attach(G19.data)
Species

# there are a multitude of object types in R, this is always an important issue!

objects()
attach(F24.size)
# I want the mean of SCL in this table
mean(SCL)  ## what is wrong?
SCL  ## there are NAs in this variable
?mean
mean(SCL, na.rm = T)

# but maybe I want the mean SCL for a specific group in this dataset
mean(SCL[which(Clade == "Chelidae")], na.rm = T)  ## only SCL whose Clade is Chelidae

# You can do that for each Clade, or use tapply for applying a function to 
## groups of values
?tapply
tapply(SCL, Clade, FUN = mean)  ## what is missing here?

tapply(SCL, Clade, FUN = mean, na.rm = T) 

# you can apply any function, let's check the maximum SCL now
tapply(SCL, Clade, max, na.rm = T)  ## warning message
SCL[which(Clade == "Dermochelyidae")]  ## this is the reason

# another very useful function that can do similar things, is aggregate
?aggregate
aggregate(SCL ~ Clade, F24.size, mean)
tapply(SCL, Clade, FUN = mean, na.rm = T)  ## same results

# aggregate can do interactions between variables, for example
names(G19.data)  ## mean dorsal cranial length per group and lifestyle
attach(G19.data)

# let's aggregate DCL per group and lifestyle and calculate the mean
aggregate(`DCL (mm)` ~ Group + Lifestyle, G19.data, mean)
# aquatic/marine Crocodylia have a DCL of 755.6444 mm, but 
## semi-aquatic/freshwater Crocodylia have 379.1041 mm


# which is the maximum value?
GL.DCL = aggregate(`DCL (mm)` ~ Group + Lifestyle, G19.data, max)
which.max(GL.DCL$`DCL (mm)`)
# now check the maximum value and organize the results in min to max values
sort(GL.DCL$`DCL (mm)`)

# let's now say I want to reorder the GL.DCL object based on DCL
names(GL.DCL)
attach(GL.DCL)

# using the function order() 
order(GL.DCL[,3])  ## this is ordering DCL from small to large
# now use it as a vector for the order of the rows in the dataframe
GL.DCL[order(GL.DCL[,3]),]
GL.DCL = GL.DCL[order(GL.DCL[,3]),]  ## this will replace the order

rownames(GL.DCL) = 1:11
GL.DCL


################################################################################
# Let's subset a dataset
head(F24.size)
levels(as.factor(F24.size$Clade))  ## check which names are there
which(F24.size$Clade == "Chelidae")
Chelidae = F24.size[which(F24.size$Clade == "Chelidae"), ] ## subset 
## only chelids

# very nice summary function
summary(Chelidae)  ## there are 35 lines in this
# now let's just keep the first 10; how would you do it?
Chelidae.15 = Chelidae[1:15,]
# or a subset within this list
Chelidae.10.35 = Chelidae[10:35,]

?intersect
intersect(Chelidae.15, Chelidae.10.35)  ## did not work, why? Look at Help, it needs vector
chel.inter = intersect(Chelidae.15$Species, Chelidae.10.35$Species)  ## which species overlap?
Chelidae.subset = Chelidae[which(Chelidae$Species == chel.inter),]
Chelidae.subset


setdiff(Chelidae.10.35$Species, Chelidae.15$Species)
setdiff(Chelidae.15$Species, Chelidae.10.35$Species)  ## why is there only 5?

# now let´s create an object containing only the species that are in 15 but not 10.35
difference = setdiff(Chelidae.15$Species, Chelidae.10.35$Species)
new.Chelidae = Chelidae.15[which(Chelidae.15$Species %in% difference),]
new.Chelidae



################################################################################
# Problem: is it morning, afternoon or evening?
# Morning = before 12h
# Afternoon = 12h onward but before 18h
# Evening = from 18h onward
Sys.time()
format(Sys.time(), "%D %H:%M:%S %Z")

good.day <- function(x) {
  if(format(Sys.time(), "%H") < 12) print("Good morning!")
  else if(format(Sys.time(), "%H") >= 18) print("Good evening!")
  else print("Good afternoon!")
}

good.day()
################################################################################



################################################################################
# Creating external objects
# and now let´s save it
write.table(new.Chelidae, file = "newChelidae.txt", sep = ",")  ## look at it
write.table(new.Chelidae, file = "newChelidae.txt", sep = ",", row.names = F)
write.csv(new.Chelidae, file = "newChelidae.csv", row.names = F)

# how to save a function?
save(good.day, file = "goodday-function.R")
load("goodday-function.R")

################################################################################
# How to save all the objects in the session
save.image("2024-introR.RData")



################################################################################
################################################################################
# Basics of plotting

# now plot both variables, x = norm, y = uni
plot(x = norm.var, y = uni.var)

# Let's put them both in the same dataset
var.data <- data.frame(rnorm(100), runif(100))
colnames(var.data)
colnames(var.data) <- c("Normal", "Uniform")
head(var.data)

# Let's plot again using the dataframe
plot(var.data)

plot(rnorm(100, mean = 10, sd = 0.1))

# Let's look at more interesting data
F24.size <- read.csv("./Ferreira_etal-2024/size-meas.csv")
head(F24.size)
attach(F24.size)
plot(JL, SCL)  ## plotting two variables
plot(SCL~JL)  ## a formula y~x

plot(JL, SCL, type = "b")  ## "b" points + lines
plot(JL, SCL, type = "h")  ## "h" histogram-like bars
plot(JL, SCL, type = "n")  ## plot region, but without points

# check different arguments in the plot

plot(JL, SCL, main = "Jaw length vs. Body size",
     xlab = "Jaw Length (JL)", 
     ylab = "Straight Carapace Length (SCL)",
     sub = "Allometric variation in the jaws of turtles",
     xlim = c(10, 100), # limit plotting area
     ylim = c(100, 600)) 

# plot axes should be logarithmized
plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy") 

# remove axes 
plot(JL, SCL, main = "Jaw length vs. Body size",
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     axes = F) 

# bty = box type
plot(JL, SCL, main = "Jaw length vs. Body size",
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l") 

plot(JL, SCL, main = "Jaw length vs. Body size",
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "7") 

# cex family = magnification
plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,  ## magnification of points
     cex.main = 1.3,  ## magnification of main title
     cex.sub = 1.3)  ## magnification of subtitle


# pch = point types
plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     pch = 22) 

plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     pch = 25) 


# col & bg = colors
## 1. using color names
plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     col = "blue",
     bg = "pink") 

plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     pch = 21,
     col = "blue",
     bg = "pink") 

## Using HEX Color Codes
plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     pch = 21,
     col = "#08519c",
     bg = "#fa9fb5")



################################################################################
# Saving to PDF

################################################################################
# First try
pdf(file = "JL-SCL_01.pdf", height = 4, width = 4)

plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     pch = 21,
     col = "#08519c",
     bg = "#fa9fb5")

dev.off()


################################################################################
# Second try: adjusting PDF size
pdf(file = "JL-SCL_02.pdf", height = 11, width = 8)

plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     pch = 21,
     col = "#08519c",
     bg = "#fa9fb5")

dev.off()

################################################################################
# Third try: adjusting plot size
pdf(file = "JL-SCL_03.pdf", height = 4, width = 4)
par(cex = 0.5)  ## adjusts parameters for all subsequent plots

plot(JL, SCL, main = "Jaw length vs. Body size", 
     xlab = "Log (Jaw Length [JL])",
     ylab = "Log (Straight Carapace Length [SCL])", 
     sub = "Allometric variation in the jaws of turtles",
     log = "xy",
     bty = "l",
     cex = 2,
     cex.main = 1.3,
     cex.sub = 1.3,
     pch = 21,
     col = "#08519c",
     bg = "#fa9fb5")

dev.off()




################################################################################
################################################################################
# Project 1: skull length and body size relation in turtles
# Problem 1.1: how does SCm increases in relation to SCL in Emydidae & Chelidae? 
F24.size$SCm
F24.size$SCL
# Important points:
## which are the independent and the dependent (response) variables?
## export in PDF and TIF
## I want a two-thirds page width figure for a publication in Palaeontology
## https://www.palass.org/publications/authors <- guidelines
attach(F24.size)

tiff("Emydidae_Chelidae-SCm_SCL.tif", 
     width = 110, 
     height = 70, 
     units = "mm", 
     res = 600)
par(mfrow = c(1,2), cex = 0.5)

# Emydidae
plot(x = SCL, 
     y = SCm, 
     log = "xy", 
     main = "Skull vs. carapace length in Emydidae",
     xlab = "Carapace length (SCL)",
     ylab = "Skull lenght (SCm)", 
     bty = "l",
     cex = 0)

points(x = SCL[which(F24.size$Clade != "Emydidae")], 
       y = SCm[which(F24.size$Clade != "Emydidae")], 
       pch = 16,
       col = rgb(0.5, 0.5, 0.5, 0.5))

points(x = SCL[which(F24.size$Clade == "Emydidae")], 
       y = SCm[which(F24.size$Clade == "Emydidae")], 
       pch = 15,
       cex = 1.3,
       col = rgb(136/255, 86/255, 167/255))

legend(x = "topleft", 
       legend = c("Emydidae", "Other turtles"),
       bty = "n",
       pch = c(15, 16),
       col = c(rgb(136/255, 86/255, 167/255), rgb(0.5, 0.5, 0.5, 0.5)))

# Chelidae
plot(x = SCL, 
     y = SCm, 
     log = "xy", 
     main = "Skull vs. carapace length in Chelidae",
     xlab = "Carapace length (SCL)",
     ylab = "Skull lenght (SCm)", 
     bty = "l",
     cex = 0)

points(x = SCL[which(F24.size$Clade != "Chelidae")], 
       y = SCm[which(F24.size$Clade != "Chelidae")], 
       pch = 16,
       col = rgb(0.5, 0.5, 0.5, 0.5))

points(x = SCL[which(F24.size$Clade == "Chelidae")], 
       y = SCm[which(F24.size$Clade == "Chelidae")], 
       pch = 15,
       cex = 1.3,
       col = rgb(127/255, 191/255, 123/255))

legend(x = "topleft", 
       legend = c("Chelidae", "Other turtles"),
       bty = "n",
       pch = c(15, 16),
       col = c(rgb(127/255, 191/255, 123/255), rgb(0.5, 0.5, 0.5, 0.5)))

dev.off()


# PDF
pdf("Emydidae_Chelidae-SCm_SCL.pdf", 
    width = 4.3, 
    height = 2.76)
par(mfrow = c(1,2), cex = 0.5)

# Emydidae
plot(x = SCL, 
     y = SCm, 
     log = "xy", 
     main = "Skull vs. carapace length in Emydidae",
     xlab = "Carapace length (SCL)",
     ylab = "Skull lenght (SCm)", 
     bty = "l",
     cex = 0)

points(x = SCL[which(F24.size$Clade != "Emydidae")], 
       y = SCm[which(F24.size$Clade != "Emydidae")], 
       pch = 16,
       col = rgb(0.5, 0.5, 0.5, 0.5))

points(x = SCL[which(F24.size$Clade == "Emydidae")], 
       y = SCm[which(F24.size$Clade == "Emydidae")], 
       pch = 15,
       cex = 1.3,
       col = rgb(136/255, 86/255, 167/255))

legend(x = "topleft", 
       legend = c("Emydidae", "Other turtles"),
       bty = "n",
       pch = c(15, 16),
       col = c(rgb(136/255, 86/255, 167/255), rgb(0.5, 0.5, 0.5, 0.5)))

# Chelidae
plot(x = SCL, 
     y = SCm, 
     log = "xy", 
     main = "Skull vs. carapace length in Chelidae",
     xlab = "Carapace length (SCL)",
     ylab = "Skull lenght (SCm)", 
     bty = "l",
     cex = 0)

points(x = SCL[which(F24.size$Clade != "Chelidae")], 
       y = SCm[which(F24.size$Clade != "Chelidae")], 
       pch = 16,
       col = rgb(0.5, 0.5, 0.5, 0.5))

points(x = SCL[which(F24.size$Clade == "Chelidae")], 
       y = SCm[which(F24.size$Clade == "Chelidae")], 
       pch = 15,
       cex = 1.3,
       col = rgb(127/255, 191/255, 123/255))

legend(x = "topleft", 
       legend = c("Chelidae", "Other turtles"),
       bty = "n",
       pch = c(15, 16),
       col = c(rgb(127/255, 191/255, 123/255), rgb(0.5, 0.5, 0.5, 0.5)))

dev.off()

# use dev.off() a second time to remove all par definitions
dev.off()