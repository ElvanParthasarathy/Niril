const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));

if (p.wideLogo) {
    // Decode base64
    let base64Svg = p.wideLogo.replace('data:image/svg+xml;base64,', '');
    let svg = Buffer.from(base64Svg, 'base64').toString('utf8');
    
    // Revert the very dark burgundy #46121f back to the original rich burgundy #6b131a
    svg = svg.replace(/#46121f/g, '#6b131a');
    
    // Re-encode and save
    const newBase64Svg = Buffer.from(svg).toString('base64');
    p.wideLogo = 'data:image/svg+xml;base64,' + newBase64Svg;
    
    fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
    console.log('Successfully reverted logo colors back to #6b131a in profile.json');
}
