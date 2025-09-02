// COMMON CONSTANTS / FUNCTIONS FOR LOOP PROJECT
cy.loop = {
  // FOR LONG RUNNING CHECKS. IN MILLISECONDS
  timeout: 120000,
  
  // LOOP AUTHENTICATION CREDENTIALS
  auth: {
    username: Cypress.env('ood_username'),
    password: Cypress.env('ood_password')
  },
  
  // SCREEN RESOLUTIONS => TO TEST IN DIFFERENT SCREEN SIZES
  screen: {
    height: 2000,
    smallWidth: 450,
    mediumWidth: 800,
    largeWidth: 1500,
    extralargeWidth: 2000,
  },
}