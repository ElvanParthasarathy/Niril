const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));

// Apply the Forest Green logo color (#0f523a) to the theme. 
// This matches the text in the logo, which is perfectly balanced and not as heavy as the burgundy.
p.themeColor = '#0f523a';

fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
console.log('Successfully applied balanced Forest Green logo color to profile.json');
