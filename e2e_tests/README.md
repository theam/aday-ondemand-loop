# OnDemand Loop - E2E Tests

This directory contains end-to-end (E2E) automated tests for OnDemand Loop using [Cypress](https://cypress.io).

## Overview

The E2E tests verify that OnDemand Loop works correctly from a user's perspective by simulating real browser interactions. Tests run in Docker containers for consistency across development and CI/CD environments.

See the complete [Overview section](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/#overview) in the Development Guide.

## Running Tests Locally

Prerequisites: Docker, Docker Compose, and Make utility.

**Quick Start:**
```bash
make env_up          # Start test environment
make cypress_build   # Install dependencies  
make cypress_run     # Run tests
make clean          # Clean up
```

For detailed instructions, environment variables, and all available Make targets, see [Running Tests Locally](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/#running-tests-locally).

## Test Structure

The tests are organized in `cypress/` with plugins, utilities, and configuration files.

See the complete [Test Structure](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/#test-structure) for detailed file organization.

## Writing Tests

Follow established patterns using navigation utilities and the `cy.loop` configuration object.

See [Writing Tests](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/#writing-tests) for best practices, patterns, and examples.

## Accessibility Checks

Accessibility scans are powered by [axe-core](https://github.com/dequelabs/axe-core) and [cypress-axe](https://github.com/component-driven/cypress-axe).

1. Visit the page or component under test.
2. Call `cy.runA11y()` to inject axe and scan the current page.
3. Optionally scope or customize the scan:
   ```js
   cy.runA11y({
     context: '#dialog',
     options: {
       includedImpacts: ['critical', 'serious', 'moderate'],
     },
     skipFailures: true, // only log violations
   })
   ```

The default configuration targets WCAG 2 A/AA rules and fails the test on serious accessibility issues. Override the defaults through `Cypress.env('axe')` in `cypress.config.js` or per-test overrides shown above.

When violations are detected, the Cypress command log links to the detailed failure data. Click an `axe` entry to see the impacted nodes, rendered HTML, and suggested fixes. You can also open the browser DevTools console while the test runs to view a grouped summary table for every violation that `cy.runA11y()` reports.

## Adding New Tests

Create test files in `cypress/e2e/` with the `.cy.js` extension following naming conventions.

See [Adding New Tests](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/#adding-new-tests) for step-by-step instructions and examples.

## CI/CD Integration

Tests automatically run in GitHub Actions on pushes, pull requests, and manual dispatch.

See [CI/CD Integration](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/#cicd-integration) for workflow details and test artifacts.

## Troubleshooting

For common issues like authentication errors, connection problems, or SSL certificate issues, see [Troubleshooting](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/#troubleshooting).

---

**Complete Documentation:** [E2E Tests Guide](https://iqss.github.io/ondemand-loop/development_guide/e2e_tests/)