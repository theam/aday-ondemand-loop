const { defineConfig } = require('cypress');
const loadCredentials = require('./read_credentials');
const { username, password } = loadCredentials();

module.exports = defineConfig({
  e2e: {
    baseUrl: 'https://ood',
    chromeWebSecurity: false,
    video: false,
  },
  env: {
    ood_username: username,
    ood_password: password,
  },
});
