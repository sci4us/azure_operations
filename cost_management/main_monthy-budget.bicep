// Creation of a monthly budget for the Azure Subscription
targetScope = 'subscription'

@description('Name of the budget being created.')
param budgetName string = 'monthly_budget'

@description('Total amount of the budget')
param amount int = 150  // The amount is in USD

@description('Time grain is the amount of time to track the budget. It can be Monthly, Quarterly, or Annually')
param timeGrain string = 'Monthly'

@description('Start date for the budget')
param startDate string = '2024-12-01'

@description('End date for the budget')
param endDate string 

@description('Threshold value for the first notification (as a percentage of the total budget)')
param firstThreshold int = 80

@description('Threshold value for the second notification (as a percentage of the total budget)')
param secondThreshold int = 90

@description('Threshold value for the third notification (as a percentage of the total budget)')
param thirdThreshold int = 100

@description('Threshold value for the first forecast notification (as a percentage of the total budget)')
param forecastThreshold int = 101

@description('Email addresses being notified when the budget notifications ')
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
