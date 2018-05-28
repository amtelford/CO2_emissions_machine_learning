# CO2_emissions_machine_learning
Modelling of CO2 emissions data from the International Energy Agency

This set of scripts in R was designed to import and tidy some data
from the International Energy Agency (IEA) and to model CO2 emissions
based on a number of predictors.
Based on IEA data from CO2 emissions from fuel combustion, 2017 edition © OECD/IEA 2017, www.iea.org/statistics,
Licence: www.iea.org/t&c; as modified by Andrew M. Telford.
Data source: https://www.iea.org/media/statistics/CO2Highlights.XLS
All variables are described in the original dataset.

COMMENTS ON MODEL:
* GDP and TPES appear to be strongly correlated. The model was tested by removing each variable. TPES appears to be a better predictor than GDP.
* China appears to be an outlier in the general CO2 emission trend. It was removed from the model for training.
* The CO2 data is highly skewed. Transformations such as log, BoxVox and PCA did not help. It was found that a Quantile Regression model worked better than a Generalised Lienar Model to address the issue with skewedness.
* The final model predicts the trend of CO2 emissions in time fairly well for most countries. I am working on an appropriate figure for the goodness of fit of a Quantile Regression multivariate model. Inputs are welcome.

Disclaimer: This work is partially based on the CO2 emissions from fuel combustion, 2017 edition dataset, developed by the International Energy Agency, © OECD/IEA 2017, but the resulting work has been prepared by Andrew M. Telford and does not necessarily reflect the views of the International Energy Agency.
