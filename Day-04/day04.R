################################################################################
## Day 04

################################################################################
# Correlations & Regression
# When we have two continuous variables, we can test whether they are correlated
# Correlation is defined in terms of the variance of x, the variance of y, and 
## the covariance of x and y, the way they vary together. The formula to obtain
## the correlation between x and y is the covariance between x and y, divided
## by the square root of the variance of x times the variance of y.

# Let's load the dataset again
F24.size <- read.csv("./datasets/Ferreira_etal-2024/size-meas.csv", 
                     header = TRUE)

head(F24.size)
attach(F24.size)
# Let's test the correlation between SCm and SCL
# Let's first take a look at it
plot(SCm, SCL)  ## it looks like there is a strong correlation
var(SCm)  ## has NAs
var(SCm, na.rm = T)
var(SCL, na.rm = T)

var(SCm, SCL, na.rm = T)  ## if var has two arguments, it calculates the covariance

# Thus, the correlation should be:
var(SCm, SCL, na.rm = T)/(sqrt(var(SCm, na.rm = T)*var(SCL, na.rm = T)))
#0.5285097 is not a strong correlation

# of course, there is an implement function to calculate that, let's check
cor(SCm, SCL)  ## same result

################################################################################
# Problem 1.2: how to correct that?
# We need a new dataset in which all data points have both values
complete.cases(SCm, SCL)
head(F24.size)
SCm.SCL <- F24.size[complete.cases(SCm, SCL), 6:7]
SCm.SCL

cor(SCm.SCL$SCm, SCm.SCL$SCL)  ## results are different, do you know why?

## we have to keep only the values that are in BOTH variables

# Thus, the correlation should be:
var(SCm.SCL$SCm, SCm.SCL$SCL)/(sqrt(var(SCm.SCL$SCm)*var(SCm.SCL$SCL)))
# 0.8841411 is a strong correlation!

# if you want to determine the significance of a correlation, use:
cor.test(SCm.SCL$SCm, SCm.SCL$SCL)  ## highly significant

# use cor to test the correlation between all variables in a dataframe
cor(F24.size)  ## we have to remove the non-numeric columns and deal with NAs
cor(F24.size[complete.cases(F24.size[,-c(1:3)]),-c(1:3)])

# do not over rely on correlation between two variables as they can be misleading
# check more complex models and also whether an additional category can change
## the explanation of the correlation. For example, using coplot:
coplot(SCm ~ SCL | Clade, pch = 16, col = "red")


################################################################################
# Regressions  
attach(SCm.SCL)

# using the implemented function, linear model (lm):
lm(SCm~SCL)

# let's inspect the object
SCm.SCL.lm <- lm(SCm~SCL)
summary(SCm.SCL.lm)  ## nice summary statistics of the model

SCm.SCL.lm$coefficients  ## intercept and slope
print(SCm.SCL.lm$coefficients)  ## a way to print those results

# let's plot the data and the regression line
plot(x = SCL,
     y = SCm,
     main = "Skull vs. carapace length in turtles",
     xlab = "Carapace length (SCL)",
     ylab = "Skull lenght (SCm)", 
     bty = "l",
     pch = 16,
     col = rgb(0,0,0,0.5))
abline(SCm.SCL.lm, col = "red", lwd = 2)

# regression formulae can be used to predict values of y based on new values of x
## let's predic the value of SCm when SCL = 645
new.SCm = data.frame(SCL = 645)
pred <- predict(SCm.SCL.lm, newdata = new.SCm, interval = "confidence")
pred

# let's now create two scatterplots and linear regression analyses with different degrees of point scatter
set.seed(123)  ## for reproducibility
# high scatter
x1 <- rnorm(50, mean = 10, sd = 5)
y1 <- 2*x1 + rnorm(50, mean = 0, sd = 10)
high.scatter.lm <- lm(y1 ~ x1)

# low scatter
x2 <- rnorm(50, mean = 10, sd = 5)
y2 <- 2*x2 + rnorm(50, mean = 0, sd = 2)
low.scatter.lm <- lm(y2 ~ x2)

# plot both
par(mfrow = c(1,2), cex = 0.8)
# high scatter
plot(x = x1,
     y = y1,
     main = "High scatter",
     xlab = "X variable",
     ylab = "Y variable", 
     bty = "l",
     pch = 16,
     col = rgb(0,0,0,0.5))
abline(high.scatter.lm, col = "red", lwd = 2)
legend(x = "topleft",
       legend = c(paste("y = ", 
                        round(high.scatter.lm$coefficients[1], digits = 2), 
                        " + ", 
                        round(high.scatter.lm$coefficients[2], digits = 2), 
                        "x"), ""),
       bty = "n",
       cex = 0.8)
# low scatter
plot(x = x2,
     y = y2,
     main = "Low scatter",
     xlab = "X variable",
     ylab = "Y variable",
     bty = "l",
     pch = 16,
     col = rgb(0,0,0,0.5))
abline(low.scatter.lm, col = "red", lwd = 2)
legend(x = "topleft",
       legend = c(paste("y = ",
                        round(low.scatter.lm$coefficients[1], digits = 2), 
                        " + ", 
                        round(low.scatter.lm$coefficients[2], digits = 2), 
                        "x"), ""),
       bty = "n",
       cex = 0.8)


deviance(high.scatter.lm)  ## higher deviance
deviance(low.scatter.lm)   ## lower deviance

dev.off()

################################################################################
################################################################################
# Project 1: skull length and body size relation in turtles
# Problem 1.2: finish the plot including the regression formula on it
# hint: use the model object and a second legend() 

## we did not have time to do this project, so I will put it in the final project
pdf(file = "./Day-04/Skull_vs_Carapace_Length_Turtles.pdf", 
    width = 10, 
    height = 5)
par(mfrow = c(1,2), cex = 0.5)

# Emydidae
plot(x = SCL, 
     y = SCm,  
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

Emydidae.lm <- lm(SCm[which(F24.size$Clade == "Emydidae")] ~ 
                    SCL[which(F24.size$Clade == "Emydidae")])

abline(Emydidae.lm, col = rgb(136/255, 86/255, 167/255), lwd = 2)

## add a second legend with the formula
legend(x = "bottomright", 
       legend = c(paste("y = ", 
                        round(Emydidae.lm$coefficients[1], digits = 2), 
                        " + ", 
                        round(Emydidae.lm$coefficients[2], digits = 2), 
                        "x"), ""),
       bty = "n",
       cex = 0.8)


# Chelidae
plot(x = SCL, 
     y = SCm, 
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
       col = c(rgb(127/255, 191/255, 123/255), 
               rgb(0.5, 0.5, 0.5, 0.5)))


Chelidae.lm <- lm(SCm[which(F24.size$Clade == "Chelidae")] ~ 
                    SCL[which(F24.size$Clade == "Chelidae")])

abline(Chelidae.lm, col = rgb(127/255, 191/255, 123/255), lwd = 2)

legend(x = "bottomright", 
       legend = c(paste("y = ", 
                        round(Chelidae.lm$coefficients[1], digits = 2), 
                        " + ", 
                        round(Chelidae.lm$coefficients[2], digits = 2), 
                        "x"), ""),
       bty = "n",
       cex = 0.8)

dev.off()