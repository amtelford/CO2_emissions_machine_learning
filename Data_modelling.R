## Author: Andrew M. Telford
## Date: 28/05/2018
## Model CO2 emissions using Quantile Regression

library(caret)
library(dplyr)
library(tidyr)
library(miscTools)
set.seed(333)

## Partition data
data.clean <- full_data[complete.cases(full_data), ]
inTrain <- createDataPartition(y=data.clean$co2, p=0.7, list=F)
training <- data.clean[inTrain,]
testing <- data.clean[-inTrain,]
featurePlot(x=training[,c("population","gdp", "tpes", "GP", "EG", "CE")],
            y=training$co2,
            plot="pairs")

## Check for skewedness of CO2 variable
par(mfrow=c(1,2))
hist(data.clean$co2, main="", xlab = 'CO2 emissions [MegaTonnes]')
plot(ecdf(data.clean$co2), main="", xlab = 'CO2 emissions [MegaTonnes]') ## Cumulative frequencies
title('Skewedness of outcome', outer=TRUE)
## Outcome is very skewed. Log, BoxCox or PCA preprocessing not helping. GLM model not appropriate.

## Check for predictor correlations
M <- abs(cor(data.clean[,c(3,5,6,7,8,9,10)])) ## Calculate the correlation between varaibles
## and write them into a matrix M. Leave out the OUTCOME column that you want
## to predict, in this case column 4.
diag(M) <- 0 ## Remove diagonal elements, as each variable correlates to
## itself (value = 1)
which(M > 0.8, arr.ind=T, useNames = T) ## Show variables with a correlation above 80%
par(mfrow=c(1,1))
plot(data.clean$tpes, data.clean$gdp)
## Correlation > 80% between TPES and GDP

## Predictors importance
nearZeroVar(data.clean, saveMetrics=T)
## All predictors are good.

## Quantile Regression model with predictors POPULATION, REGION, YEAR AND TPES
lambdaGrid <- expand.grid(lambda = 10^seq(2, -10, length=7))
rqlasso <- train(co2~population+tpes+region+year, method='rqlasso', tuneGrid = lambdaGrid, data=training)
rqlasso

##Results on training data
train.predict.rqlasso <- predict(rqlasso, newdata=training)
train.rqlasso.res = training$co2-train.predict.rqlasso

## China case
data.china <- filter(training, country=='People\'s Rep. of China')
china.predict.rqlasso <- predict(rqlasso, newdata=data.china)
china.rqlasso.res <- data.china$co2-china.predict.rqlasso

## Plot results of modelling on Training dataset (China highlighted)
par(mfrow=c(1,2))
plot(train.predict.rqlasso, training$co2, pch=19, col=rgb(blue = 0.7, red=0, green=0.3, alpha=0.2), xlab='CO2 Predicted [MegaTonnes]', ylab='CO2 Actual [MegaTonnes]')
points(china.predict.rqlasso, data.china$co2, col='orange', pch=19)
abline(0,1, col='red', lwd=2)
plot(train.predict.rqlasso, train.rqlasso.res,pch=19, col=rgb(blue = 0.7, red=0, green=0.3, alpha=0.2), xlab='CO2 Predicted [MegaTonnes]', ylab='Residuals [MegaTonnes]')
points(china.predict.rqlasso, china.rqlasso.res, col='orange', pch=19)
abline(0,0, col='red', lwd=2)
title("Modelling of full Training dataset", outer=TRUE)

## Plot results of modelling on Testing dataset (China excluded)
testPredict.rqlasso <- predict(rqlasso, newdata=testing)
par(mfrow=c(1,2))
plot(testPredict.rqlasso, testing$co2, pch=19, col=rgb(blue = 0.7, red=0, green=0.3, alpha=0.2), xlab='CO2 Predicted [MegaTonnes]', ylab='CO2 Actual [MegaTonnes]')
abline(0,1, col=2, lwd=2)
testPredict.rqlasso.res = testing$co2-testPredict.rqlasso
plot(testPredict.rqlasso, testPredict.rqlasso.res, pch=19, col=rgb(blue = 0.7, red=0, green=0.3, alpha=0.2), xlab='CO2 Predicted [MegaTonnes]', ylab='Residuals [MegaTonnes]')
abline(0,0, col=2, lwd=2)
title("Modelling of Testing dataset without China", outer=TRUE)

## Example of using the model to predict CO2 in a specific country (e.g. US)
data.country <- filter(data.clean, country=='United States')
rqlasso.country <- predict(rqlasso, newdata=data.country)
par(mfrow=c(1,1))
plot(data.country$year, data.country$co2, pch=19, col=rgb(blue = 0.7, red=0, green=0.3, alpha=0.5), xlab='Year', ylab='CO2 emissions [MegaTonnes]', ylim=c(0,6000))
lines(data.country$year, rqlasso.country,lwd=3, col=2)
title("Modelling of CO2 emissions for the United States", outer=TRUE)
