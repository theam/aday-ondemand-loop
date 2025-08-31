const fs = require('fs');
const path = require('path');

function loadCredentials() {
  const username = process.env.LOOP_USERNAME;
  const password = process.env.LOOP_PASSWORD;
  if (username && password) {
    return { username, password };
  }
  const credentialsPath = path.join(__dirname, 'credentials.json');
  if (fs.existsSync(credentialsPath)) {
    const raw = fs.readFileSync(credentialsPath, 'utf8');
    const parsed = JSON.parse(raw);
    return { username: parsed.username, password: parsed.password };
  }
  return { username: undefined, password: undefined };
}

module.exports = loadCredentials;
