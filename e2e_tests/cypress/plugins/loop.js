const path = require('path');
const fs = require('fs');
const MESSAGE_INDENTATION = '      '

/// <reference types="cypress" />
// ***********************************************************
// Loop project Cypress plugins configuration
//
// This file configures Cypress for the OnDemand Loop project
// with credential loading, environment setup, and custom tasks
// ***********************************************************

/**
 * @type {Cypress.PluginConfig}
 */
module.exports = (on, config) => {
  // Set up custom tasks for logging and other utilities
  on('task', {
    log(message) {
      console.log(MESSAGE_INDENTATION + message)
      return null
    }
  })

  // Load credentials from multiple sources
  const credentialsPath = path.resolve(process.cwd(), 'credentials.json')
  
  if (fs.existsSync(credentialsPath)) {
    const credentials = JSON.parse(fs.readFileSync(credentialsPath));
    config.env['ood_username'] = credentials.username
    config.env['ood_password'] = credentials.password
    console.log(`Loop credentials loaded from: ${credentialsPath}`)
  }

  // Environment variables override file-based credentials
  if (process.env['LOOP_USERNAME']) {
    config.env['ood_username'] = process.env['LOOP_USERNAME']
    console.log('Overriding username with $LOOP_USERNAME')
  }
  
  if (process.env['LOOP_PASSWORD']) {
    config.env['ood_password'] = process.env['LOOP_PASSWORD']
    console.log('Overriding password with $LOOP_PASSWORD')
  }

  // Environment-specific base URLs for Loop
  const loopEnvironments = {
    "local": "https://localhost:22200",
    "development": "https://localhost:22200",
    "test": "https://localhost:22200"
  }

  const loopEnvironment = process.env['LOOP_ENVIRONMENT'] || 'local'
  console.log(`Using Loop environment: ${loopEnvironment}`)

  const baseUrl = loopEnvironments[loopEnvironment] || config.baseUrl
  if (baseUrl) {
    config.baseUrl = baseUrl
    config.env['baseUrl'] = baseUrl
  }

  // Credential validation and logging
  const credentialsCheck = config.env['ood_username'] && config.env['ood_password'] ? 'provided' : 'not provided'
  console.log(`Loop credentials: ${credentialsCheck} - username: ${config.env['ood_username']}`)
  console.log(`Loop baseUrl: ${config.baseUrl}`)

  return config
}