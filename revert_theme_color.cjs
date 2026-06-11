const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));

// Remove the themeColor override so the receipt reverts to its default standard blue colors
delete p.themeColor;

fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
console.log('Successfully reverted theme color in profile.json');
