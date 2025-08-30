const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'https://ood',
    chromeWebSecurity: false,
    video: false,
  },
});
