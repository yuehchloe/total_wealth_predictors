options(scipen=999) # Get rid of scientific notation
rm(list = ls(all.names = TRUE)) # Clear Global Environment
# setwd("c:/Users/yuehchloe/Desktop/Portfolio")
data_tr <- read.table ("data_tr.txt", header = TRUE, sep = "\t", dec = ".")[, -1]

library(readr)
library(dplyr)
library(MASS)
# library(ggplot2)
library(glmnet)
library(splines)

# Preliminary Analysis

# Check for missing values
sum(is.na(data_tr)) # no missing values


# Find the outliers of Variables
# Use plots to find points with high residuals and high leverage.
names(data_tr)
# reg_ira <- lm(tw ~ ira, data=data_tr)
# plot(reg_ira)
# 
# reg_e401 <- lm(tw ~ e401, data=data_tr)
# plot(reg_e401)
# 
# reg_nifa <- lm(tw ~ nifa, data=data_tr)
# plot(reg_nifa)
# 
# reg_inc <- lm(tw ~ inc, data=data_tr)
# plot(reg_inc)
# 
# reg_hequity <- lm(tw ~ hequity, data=data_tr)
# plot(reg_hequity)
# 
# reg_educ <- lm(tw ~ educ, data=data_tr)
# plot(reg_educ)
# 
# reg_male <- lm(tw ~ male, data=data_tr)
# plot(reg_male)
# 
# reg_twoearn <- lm(tw ~ twoearn, data=data_tr)
# plot(reg_twoearn)
# 
# reg_age <- lm(tw ~ age, data=data_tr)
# plot(reg_age)
# 
# reg_fsize <- lm(tw ~ fsize, data=data_tr)
# plot(reg_fsize)
# 
# reg_marr <- lm(tw ~ marr, data=data_tr)
# plot(reg_marr)

# Exclude outliers
data_in <- data_tr %>% slice(-c(2233, 2290, 2511, 2657, 2714, 3736, 3760, 4364, 4620, 5430, 5580, 5670, 5768, 6922))
dim(data_in)


# Handling X Variables
# Among home ownership variables, hequity is omitted to avoid perfect collinearity
# nohs, hs, smcol, col are omitted because they serve the same purpose as educ
# Thus only ira, e401, nifa, inc, hmort, hval, educ, male, twoearn, age, fsize, marr are used in this study


# Use scatterplots to check relationships among the variables
pairs(~ tw + ira + e401 + nifa + inc + hmort + hval + educ + age + fsize, data = data_tr)
# ira, nifa, inc, educ, age, fsize might need spline transformations

# Linear Transformations of X variables: use Natural Cubic Splines (10-folds to choose knots)
### ira
ira <- data_in$ira
y <- data_in$tw
dat <- as.data.frame(cbind(y,ira))
n <- length(y)
k <- 10
max_knots <- 30
ii <- sample(rep(1:k, length = n))
MSPE <- matrix(ncol = max_knots - 1, nrow = k)

for (j in 1:k){
  hold <- (ii == j)
  train <- (ii != j)
  min_X <- min(ira[train])
  max_X <- max(ira[train])
  # Loop though the different models by allowing different amounts of knots
  for(num_knots in 2:max_knots) {
    knots <- seq(from = 0, to = 1000, length = num_knots + 2)
    knots <- knots[2:num_knots+1]
    model <- lm(y ~ ns(ira, knots = knots, Boundary.knots = c(0,1000)), data = dat[train,])
    pr <- predict(model, newdata = dat[hold,])
    MSPE[j,num_knots-1] <- mean((y[hold] - pr)^2)
  }
}
MSPE <- colMeans(MSPE)
cbind(0:(max_knots-2), MSPE) 
# For ira, 11 knots has the lowest MSPE


### nifa 
nifa <- data_in$nifa
y <- data_in$tw
dat <- as.data.frame(cbind(y, nifa))
n <- length(y)
k <- 10
max_knots <- 30
ii <- sample(rep(1:k, length = n))
MSPE <- matrix(ncol = max_knots - 1, nrow = k)

for (j in 1:k){
  hold <- (ii == j)
  train <- (ii != j)
  min_X <- min(nifa[train])
  max_X <- max(nifa[train])
  # Loop though the different models by allowing different amounts of knots
  for(num_knots in 2:max_knots) {
    knots <- seq(from = 0, to = 1000, length = num_knots + 2)
    knots <- knots[2:num_knots+1]
    model <- lm(y ~ ns(nifa, knots = knots, Boundary.knots = c(0,1000)), data = dat[train,])
    pr <- predict(model, newdata = dat[hold,])
    MSPE[j,num_knots-1] <- mean((y[hold] - pr)^2)
  }
}
MSPE <- colMeans(MSPE)
cbind(0:(max_knots-2), MSPE)
# For nifa, 10 knots has the lowest MSPE


### inc
inc <- data_in$inc
y <- data_in$tw
dat <- as.data.frame(cbind(y, inc))
n <- length(y)
k <- 10
max_knots <- 30
ii <- sample(rep(1:k, length = n))
MSPE <- matrix(ncol = max_knots - 1, nrow = k)

for (j in 1:k) {
  hold <- (ii == j)
  train <- (ii != j)
  min_X <- min(inc[train])
  max_X <- max(inc[train])
  
  # Loop through the different models by allowing different amounts of knots
  for (num_knots in 2:max_knots) {
    knots <- seq(from = min_X, to = max_X, length = num_knots + 2)
    knots <- knots[2:(num_knots + 1)]
    
    model <- tryCatch(
      lm(y ~ ns(inc, knots = knots, Boundary.knots = c(min_X, max_X)), data = dat[train,]),
      error = function(e) NULL
    )
    
    if (!is.null(model)) {
      pr <- predict(model, newdata = dat[hold,])
      MSPE[j, num_knots - 1] <- mean((y[hold] - pr)^2)
    } else {
      MSPE[j, num_knots - 1] <- NA
    }
  }
}

MSPE <- colMeans(MSPE, na.rm = TRUE)
cbind(0:(max_knots - 2), MSPE)
# For inc, O knots has the lowest MSPE, so no need for transformation


### educ
educ <- data_in$educ
y <- data_in$tw
dat <- as.data.frame(cbind(y,educ))
n <- length(y)
k <- 10
max_knots <- 30
ii <- sample(rep(1:k, length = n))
MSPE <- matrix(ncol = max_knots - 1, nrow = k)

for (j in 1:k){
  hold <- (ii == j)
  train <- (ii != j)
  # Loop though the different models by allowing different amounts of knots
  for(num_knots in 2:max_knots) {
    # Adjusting the range for knots placement
    min_X <- min(educ[train])
    max_X <- max(educ[train])
    knots <- seq(from = min_X, to = max_X, length = num_knots + 2)
    knots <- knots[2:(num_knots + 1)]
    model <- try(lm(y ~ ns(educ, knots = knots, Boundary.knots = c(min_X, max_X)), data = dat[train,]), silent = TRUE)
    if (inherits(model, "try-error")) {
      MSPE[j, num_knots - 1] <- NA
    } else {
      pr <- predict(model, newdata = dat[hold,])
      MSPE[j, num_knots - 1] <- mean((y[hold] - pr)^2)
    }
  }
}
MSPE <- colMeans(MSPE, na.rm = TRUE)
cbind(0:(max_knots - 2), MSPE)
# For educ, 8 knots has the lowest MSPE


### age
age <- data_in$age
y <- data_in$tw
dat <- as.data.frame(cbind(y, age))
n <- length(y)
k <- 10
max_knots <- 30
ii <- sample(rep(1:k, length = n))
MSPE <- matrix(ncol = max_knots - 1, nrow = k)

for (j in 1:k) {
  hold <- (ii == j)
  train <- (ii != j)
  
  # Adjusting the range for knots placement
  min_X <- min(age[train])
  max_X <- max(age[train])
  
  # Loop through the different models by allowing different amounts of knots
  for (num_knots in 2:max_knots) {
    knots <- seq(from = min_X, to = max_X, length = num_knots + 2)
    knots <- knots[2:(num_knots + 1)]
    
    model <- try(lm(y ~ ns(age, knots = knots, Boundary.knots = c(min_X, max_X)), data = dat[train,]), silent = TRUE)
    
    if (inherits(model, "try-error")) {
      MSPE[j, num_knots - 1] <- NA
    } else {
      pr <- predict(model, newdata = dat[hold,])
      MSPE[j, num_knots - 1] <- mean((y[hold] - pr)^2)
    }
  }
}

MSPE <- colMeans(MSPE, na.rm = TRUE)
cbind(0:(max_knots - 2), MSPE)
# For age, 3 knots has the lowest MSPE


### fsize
fsize <- data_in$fsize
y <- data_in$tw
dat <- as.data.frame(cbind(y, fsize))
n <- length(y)
k <- 10
max_knots <- 30
ii <- sample(rep(1:k, length = n))
MSPE <- matrix(ncol = max_knots - 1, nrow = k)

for (j in 1:k) {
  hold <- (ii == j)
  train <- (ii != j)
  
  # Adjusting the range for knots placement
  min_X <- min(fsize[train])
  max_X <- max(fsize[train])
  
  # Loop through the different models by allowing different amounts of knots
  for (num_knots in 2:max_knots) {
    knots <- seq(from = min_X, to = max_X, length = num_knots + 2)
    knots <- knots[2:(num_knots + 1)]
    
    model <- try(lm(y ~ ns(fsize, knots = knots, Boundary.knots = c(min_X, max_X)), data = dat[train,]), silent = TRUE)
    
    if (inherits(model, "try-error")) {
      MSPE[j, num_knots - 1] <- NA
    } else {
      pr <- predict(model, newdata = dat[hold,])
      MSPE[j, num_knots - 1] <- mean((y[hold] - pr)^2)
    }
  }
}

MSPE <- colMeans(MSPE, na.rm = TRUE)
cbind(0:(max_knots - 2), MSPE)
# For fsize, 8 knots has the lowest MSPE

# GAM Model
gam <- lm(tw ~ ns(ira, 11) + e401 + ns(nifa, 10) + inc + hequity + ns(educ, 5) + male + twoearn + ns(age, 3) + ns(fsize, 8) + marr, data=data_in)
mse_gam <- mean(residuals(gam)^2)

# 10-folds Cross validation for Ridge regression, Lasso and Stepwise####
X <- as.matrix(data_in[,-1])
y <- data_in$tw
n <- length(y)
k <- 10
ii <- sample(rep(1:k, length = n))
pr.stepwise_backward <- pr.stepwise_forward <- pr.lasso <- pr.ridge <- rep (NA, length(y))

for (j in 1: k){
  hold <- (ii == j)
  train <- (ii != j)
  ## Stepwise
  full <- lm(tw ~., data = data_in[train,])
  null <- lm(tw ~1, data = data_in[train,])
  a <- stepAIC(null, scope = list(lower=null, upper=full), direction = 'forward')
  b <- stepAIC(full, scope = list(lower=null, upper=full), direction = 'backward')
  pr.stepwise_backward[hold] <- predict(b, newdata=data_in[hold,])
  pr.stepwise_forward[hold] <- predict(a, newdata=data_in[hold,])
  ## Ridge and Lasso
  xx.tr <- X[train, -1]
  y.tr <- y[train]
  xx.te <- X[hold,-1]
  ridge.cv <- cv.glmnet(x=as.matrix(xx.tr), y=y.tr, nfolds=k, alpha=0)
  lasso.cv <- cv.glmnet(x=as.matrix(xx.tr), y=y.tr, nfolds=k, alpha=1)
  pr.lasso[hold] <- predict(lasso.cv, newx=as.matrix(xx.te))
  pr.ridge[hold] <- predict(ridge.cv, newx=as.matrix(xx.te))
}

mspe_step_backward <- mean((pr.stepwise_backward-y)^2)
mspe_step_forward <- mean((pr.stepwise_forward-y)^2)
mspe.lasso <- mean((pr.lasso-y)^2)
mspe.ridge <- mean((pr.ridge-y)^2)
c(mspe_step_backward, mspe_step_forward, mspe.lasso, mspe.ridge, mse_gam)
# Results say that GAM is the best out of the 5 models


# Comparing GAM and Stepwise
summary(gam)
# Stepwise Backward
# null <- lm(tw ~ 1, data = data_tr)
# full <- lm(tw ~., data = data_tr)
model_stepback <- stepAIC(full, scope=list(lower=null, upper=full), direction="backward")
# plot(model_stepback)
summary(model_stepback)


# Save Model
my_model <- gam
data_te <- read.table ("data_for_prediction.txt", header = TRUE, sep = "\t", dec = ".")
my_predictions <- predict(my_model, newx = as.matrix(data_te[,c(2:18)]))
write.table(my_predictions, file = 'my_predictions.txt')
