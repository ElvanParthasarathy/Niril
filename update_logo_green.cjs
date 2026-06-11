const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));

if (p.wideLogo) {
    // Decode base64
    let base64Svg = p.wideLogo.replace('data:image/svg+xml;base64,', '');
    let svg = Buffer.from(base64Svg, 'base64').toString('utf8');
    
    // Replace the dark Forest Green (#0f523a) with the bright PVS Green (#388e3c)
    svg = svg.replace(/#0f523a/g, '#388e3c');
    
    // Re-encode and save
    const newBase64Svg = Buffer.from(svg).toString('base64');
    p.wideLogo = 'data:image/svg+xml;base64,' + newBase64Svg;
    
    fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
    console.log('Successfully updated logo green to match PVS green (#388e3c) in profile.json');
} else {
    console.log('No wideLogo found in profile.json');
}
