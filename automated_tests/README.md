# OnDemand Loop - Automated Tests

This directory contains end-to-end (E2E) automated tests for OnDemand Loop using [Cypress](https://cypress.io).

## Overview

The automated tests verify that OnDemand Loop works correctly from a user's perspective by simulating real browser interactions. Tests run in Docker containers for consistency across development and CI/CD environments.

See the complete [Overview section](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/#overview) in the Development Guide.

## Running Tests Locally

Prerequisites: Docker, Docker Compose, and Make utility.

**Quick Start:**
```bash
make env_up          # Start test environment
make cypress_build   # Install dependencies  
make cypress_run     # Run tests
make clean          # Clean up
```

For detailed instructions, environment variables, and all available Make targets, see [Running Tests Locally](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/#running-tests-locally).

## Test Structure

The tests are organized in `cypress/` with plugins, utilities, and configuration files.

See the complete [Test Structure](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/#test-structure) for detailed file organization.

## Writing Tests

Follow established patterns using navigation utilities and the `cy.loop` configuration object.

See [Writing Tests](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/#writing-tests) for best practices, patterns, and examples.

## Adding New Tests

Create test files in `cypress/e2e/` with the `.cy.js` extension following naming conventions.

See [Adding New Tests](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/#adding-new-tests) for step-by-step instructions and examples.

## CI/CD Integration

Tests automatically run in GitHub Actions on pushes, pull requests, and manual dispatch.

See [CI/CD Integration](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/#cicd-integration) for workflow details and test artifacts.

## Troubleshooting

For common issues like authentication errors, connection problems, or SSL certificate issues, see [Troubleshooting](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/#troubleshooting).

---

**Complete Documentation:** [Automated Tests Guide](https://iqss.github.io/ondemand-loop/development_guide/automated_tests/)