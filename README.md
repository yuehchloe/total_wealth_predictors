# Modeling Total Wealth Using Financial and Demographic Predictors
### Built predictive machine learning models to predict US households' total wealth. Concluded that income, non-retirement financial assets & home ownership are the biggest contributing factors to a households total wealth.

## Introduction

Predicting total wealth using various economic indicators has long intrigued economists. This paper aims to predict an individual's total wealth through statistical learning methods, utilizing data from the 1991 Survey of Income and Program Participation (SIPP). The dataset comprises 7,933 observations, with the following variables used as predictors:

- ira: Individual retirement account (IRA) (in US dollars)
- e401: Eligibility for 401(k) (1 if eligible, 0 otherwise)
- nifa: Non-401(k) financial assets (in US dollars)
- inc: Income (in US dollars)
- hmort: Home mortgage (in US dollars)
- hval: Home value (in US dollars)
- hequity: Home equity (home value minus home mortgage)
- educ: Education (in years)
- male: Gender (1 if male, 0 otherwise)
- twoearn: Dual-income households (1 if two earners, 0 otherwise)
- nohs, hs, smcol, col: Educational attainment dummies (no high school, high school, some college, college)
- age: Age
- fsize: Family size
- marr: Marital status (1 if married, 0 otherwise)

The sample includes households where the reference person is aged 25-64, at least one person is employed, and no one is self-employed. The observation units correspond to the household reference persons (or typically called head of household in tax returns).

## Preliminary Analysis

Since the sample only includes households where no one is self-employed, the variable e401(Eligibility for 401(k)) (1 if eligible, 0 otherwise), Initial examination reveals perfect collinearity among home mortgage (hmort), home value (hval), and home equity (hequity). Thus, hequity is excluded from the analysis. Similarly, the educational attainment dummies (nohs, hs, smcol, col) serve the same purpose as the Education variable and thus are also omitted.

Before starting to build models, there is a need to get rid of outliers and points with high leverage since these observations have sizable impact on the estimated regression line. According to An Introduction to Statistical Learning, high leverage points are “cause for concern if the least squares line is heavily affected by just a couple of observations, because any problems with these points may invalidate the entire fit” (Gareth et al. 98). To identify outliers and high leverage points, simple linear regressions on total wealth are used with input variables individually and then visualized through plots. Outliers are identified through the Residuals vs. Fitted plot, and high leverage points are found through the Residuals vs. Leverage plot. In the chart below, the leftmost column shows the observations that have been identified as an outlier or a high leverage point by one of the input variables. These observations are omitted when building our models. Hence, 7919 observations are left for In-Depth Analysis.

The following scatterplot matrix indicates non-linear relationships between the following variables and total wealth:
- ira: Individual retirement account (IRA) (in US dollars)
- e401: Eligibility for 401(k) (1 if eligible, 0 otherwise)
- nifa: Non-401(k) financial assets (in US dollars)
- inc: Income (in US dollars)
- educ: Education (in years)
- age: Age
- fsize: Family size

<img width="1174" height="1160" alt="image" src="https://github.com/user-attachments/assets/4405a373-03dc-4c60-965f-e62527015c4b" />

While these non-linearities may need flexible transformations, not all of them are statistically significant to the prediction of total wealth. According to the backward stepwise selection (discussed further in the next section), only the variables following variables have a significant influence on total wealth:
- ira: Individual retirement account (IRA) (in US dollars)
- e401: Eligibility for 401(k) (1 if eligible, 0 otherwise)
- nifa: Non-401(k) financial assets (in US dollars)
- inc: Income (in US dollars)
- hmort: Home mortgage (in US dollars)
- hval: Home value (in US dollars)
- male: Gender (1 if male, 0 otherwise)
- twoearn: Dual-income households (1 if two earners, 0 otherwise)
- age: Age

As such, natural cubic splines were employed on only ira, nifa, inc, and age. Natural cubic splines were chosen over cubic splines because they handle large datasets more effectively and avoid abrupt jumps in predictions. Ten-fold cross-validation was used to determine the optimal degrees of freedom for individual retirement account (ira), non-401k financial assets (nifa) and age, which were 11, 11 and 3 respectively. For inc, 0 knot has the lowest MSPE, hence there is no need for transformation.

## In-depth Analysis and Conclusion

Further analysis involved comparing LASSO, Ridge, and Stepwise regressions, all assessed through ten-fold cross-validation. Backward stepwise regression performed the best, which showed the lowest Mean Squared Prediction Error (MSPE): 1365955376.

Since the MSPE 1365955376 is quite large, a Generalized Additive Model (GAM) was fitted, using only the statistically significant variables selected by backward stepwise regression, and statistically significant knots indicated by the simple GAM model.

The final model selection favored the GAM model due to its superior performance and significance of most variables. The chosen model was:
`lm(formula = tw ~ ira_ns8 + ira_ns9 + ira_ns10 + e401 + nifa_ns7 + nifa_ns8 + nifa_ns9 + nifa_ns10 + nifa_ns11 + inc + hmort + hval + twoearn + age, data = data_in)`

<img width="724" height="790.7" alt="image" src="https://github.com/user-attachments/assets/de3109ef-0678-40f1-b54e-9c103301ee61" />

## Results Summary

**Residuals**: The residuals indicate that the median prediction error is quite low, though there are some large outliers (e.g., min and max residuals). Considering how total wealth of households vary in real life, these large outliers are acceptable.

**Coefficients**: The coefficients of the spline terms (ira_ns6, ira_ns7, ira_ns9, nifa_ns1, nifa_ns2, nifa_ns3, nifa_ns4, nifa_ns5, nifa_ns6, nifa_ns7, nifa_ns8, nifa_ns9, nifa_ns10) capture the non-linear relationships between ira and nifa and total wealth (tw). The high significance of these coefficients indicates that the spline transformations are effectively modeling the complex relationships in the data. For example, the positive coefficient for ira_ns6 suggests that increases in the ira variable at the 6th knot have a positive impact on total wealth, while the negative coefficients for ira_ns7 and ira_ns9 suggest negative impacts at those knots.

**Model Performance**: The adjusted R-squared value of 0.858 indicates that approximately 85.8% of the variance in total wealth is explained by the model. The high F-statistic and low p-value indicate that the model is highly statistically significant.

Overall, this model, which incorporates natural cubic spline transformations, provides a strong fit to the data and effectively captures the non-linear relationships between the predictor variables and total wealth.

## Conclusion

The study successfully employed advanced statistical learning methods to predict total wealth. The Generalized Additive Model, with its ability to capture non-linear relationships, provided the best fit among the models tested. Key predictors such as income, home value, and eligibility for retirement accounts were identified as significant contributors to total wealth, while factors like education and family size showed less influence than anticipated.

This analysis underscores the importance of considering non-linear relationships and the impact of various financial indicators in wealth prediction models. Future research could explore additional variables or alternative modeling techniques to further refine predictions and enhance the understanding of wealth accumulation dynamics.

The GAM model outperformed other methods with the lowest Mean Squared Error (MSE) of 1344914283. While this number seems large, it is important to consider it in the context of total wealth values, which can be in the millions of dollars.

The model results show that several factors significantly influence total wealth:
- Individual Retirement Accounts (IRA): The non-linear relationship suggests that the impact of IRAs on total wealth varies at different contribution levels.
- Eligibility for 401k: The 401(k) is an employer-provided, defined contribution retirement savings plan. Hence, it indicates whether the household head is employed.
- Non-401k financial assets: This also shows a complex, non-linear relationship with total wealth, indicating a negative association to total wealth within the first 10 knots. However, both the scatterplot and stepwise regression shows that non-401k financial assets have a slightly positive correlation with total wealth. This discrepancy originates from the intercept of the different models, with stepwise having a negative intercept and GAM having a positive intercept.
- Income: As expected, income positively correlates with total wealth, with each additional dollar of income associated with an $0.19 increase in total wealth, on average.
- Home value and mortgage: Interestingly, each dollar increase in home value is associated with a $1.07 increase in total wealth, while each dollar of mortgage is associated with a $1.01 decrease. This suggests that home equity plays a significant role in overall wealth.
- Age: Each year of age is associated with an average increase of $250.85 in total wealth, likely reflecting the accumulation of assets over time.
- Two-earner households: Surprisingly, two-earner households are associated with $4,751 less in total wealth compared to single-earner households, potentially due to factors not captured in the model such as childcare costs or lifestyle differences.
- The model explains about 85.8% of the variance in total wealth (as indicated by the adjusted R-squared value), suggesting it captures a substantial portion of the factors influencing wealth accumulation.

## Citation

James, Gareth, et al. An Introduction to Statistical Learning: with Applications in R. Springer, 2017. 
