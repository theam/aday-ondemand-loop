describe('Home page', () => {
  it('shows welcome and beta notices on first visit', () => {
    cy.visit('/', {
      auth: {
        username: Cypress.env('ood_username'),
        password: Cypress.env('ood_password'),
      },
    });
    cy.location('pathname').should('eq', '/');
    cy.contains('Welcome to OnDemand Loop!').should('be.visible');
    cy.contains('Beta Notice').should('be.visible');
  });
});
