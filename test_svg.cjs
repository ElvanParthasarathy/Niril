const fs = require('fs');
const p = JSON.parse(fs.readFileSync('tharavu/profile.json'));
fs.writeFileSync('test_svg.html', `<!DOCTYPE html><html><body><img src="${p.wideLogo}" style="height: 140px; max-width: 400px; object-fit: contain;" /></body></html>`);
