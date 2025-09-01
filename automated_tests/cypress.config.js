const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'https://localhost:22200',
    chromeWebSecurity: false,
    video: false,
    experimentalModifyObstructiveThirdPartyCode: true,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 30000,
    setupNodeEvents(on, config) {
      // Load Loop-specific plugins and configuration
      return require('./cypress/plugins/loop')(on, config)
    },
  },
});
