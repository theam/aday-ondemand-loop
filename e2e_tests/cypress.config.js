const { defineConfig } = require('cypress');

module.exports = defineConfig({
  env: {
    axe: {
      context: 'body',
      includedImpacts: ['critical', 'serious'],
      runOnly: {
        type: 'tag',
        values: ['wcag2a', 'wcag2aa'],
      },
      skipFailures: false,
    },
  },
  e2e: {
    chromeWebSecurity: false,
    video: false,
    experimentalModifyObstructiveThirdPartyCode: true,
    defaultCommandTimeout: 5000,
    requestTimeout: 5000,
    responseTimeout: 10000,
    setupNodeEvents(on, config) {
      // Load Loop-specific plugins and configuration
      return require('./cypress/plugins/loop')(on, config)
    },
  },
});
