# predicting-customer-preferences
Given existing customer survey data, the goal is to predict which computer brand customers tend to prefer. Then, the final model will be used to predict preferences from incomplete survey data.

Data includes information such as:

- "salary" - indicating the customers salary
- "age" - indicating the customers age 
- "elevel" - indicating the customers education level. 0 = less than high school, 1 = high school, 2 = some college, 3 = four-year college degree, 4 = masters degree 
- "car" - indicating the type of car the customer drives. Numbers from 1 - 20 correspond to a list of cars (ie 1 = BMW, 2 = Buick, etc)
- "zipcode" - indicating the customers zipcode. Numbers from 0 - 8 correspond to a list of zipcode areas (ie 0 = New England, 1 = Mid-Atlantic, etc)
- "credit" - indicating the amount of credit that is available to the customer
- "brand" - indicating the computer brand the customer prefers (0 = Acer, 1 = Sony)

Three different classification models were tested, and one model was chosen to make predictions on the incomplete survey data. Predictions made are included in a .csv file titled "newsurveypreds.csv". The original data files showing the complete survey data (used for training and testing) is titled "CompleteResponses.csv", and the original incomplete survey file (used to make predictions) is titled "SurveyIncomplete.csv".

A report detailing the findings is included, titled "C3T2 report summary.docx"


