const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));

// Apply the Forest Green logo color to the entire receipt
p.themeColor = '#0f523a';

fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
console.log('Successfully applied logo theme color to profile.json');
