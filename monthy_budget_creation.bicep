// Creation of a monthly budget for the Azure Subscription
targetScope = 'subscription'

// Name of the budget being created
param budgetName string = 'monthly_budget'

// Total amount of the budget
param amount int = 150  // The amount is in USD

// Time grain is the amount of time to track the budget. It can be Monthly, Quarterly, or Annually.
param timeGrain string = 'Monthly'

// Start date for the budget
param startDate string = '2024-12-01'

// End date for the budget
param endDate string 

// Threshold value for the first notification (as a percentage of the total budget)
param firstThreshold int = 80

// Threshold value for the second notification (as a percentage of the total budget)
param secondThreshold int = 90

// Threshold value for the third notification (as a percentage of the total budget)
param thirdThreshold int = 100

// Threshold value for the third notification (as a percentage of the total budget)
param forecastThreshold int = 101

// Email addresses being notified when the budget notifications 
param contactEmails array = ['technology@sci4us.org']

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    timeGrain: timeGrain
    amount: amount
    category: 'Cost'
    notifications: {
      NotificationForExceededBudget1: {
        enabled: true
        operator: 'GreaterThan'
        threshold: firstThreshold
        contactEmails: contactEmails
      }
      NotificationForExceededBudget2: {
        enabled: true
        operator: 'GreaterThan'
        threshold: secondThreshold
        contactEmails: contactEmails
      }
      NotificationForExceededBudget3: {
        enabled: true
        operator: 'GreaterThan'
        threshold: thirdThreshold
        contactEmails: contactEmails
      }
      NotificationForForecastedBudget1: {
        enabled: true
        operator: 'GreaterThan'
        threshold: forecastThreshold
        contactEmails: contactEmails
      }
    }
  }
}

output name string = budget.name
output resourceId string = budget.id
