export const NAVIGATION = {
  baseUrl: Cypress.env('baseUrl'),
  dashboardPath: '/pun/sys/dashboard',
  loopPath: '/pun/sys/loop',
}

export const visitLoopRoot = () => {
  const auth = cy.loop.auth
  const timeout = cy.loop.timeout
  cy.visit(NAVIGATION.loopPath, { 
    auth, 
    failOnStatusCode: false, 
    timeout 
  })
}