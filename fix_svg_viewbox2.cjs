const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));
let svgDataUri = p.wideLogo;

if (svgDataUri.startsWith('data:image/svg+xml;base64,')) {
    let base64Svg = svgDataUri.replace('data:image/svg+xml;base64,', '');
    let svg = Buffer.from(base64Svg, 'base64').toString('utf8');
    
    // My previous viewBox was too tight and cut off the bezier curves.
    // Let's use a very safe, padded viewBox that captures everything perfectly
    // without cutting the top of the hand or the shuttle.
    // Bounding Box calculations:
    // Min X is ~930, Min Y is ~630
    // Max X is ~1680, Max Y is ~775
    // viewBox="900 600 800 200" provides a safe 30px padding on all sides.
    svg = svg.replace(/viewBox="[^"]+"/, 'viewBox="900 600 800 200"');
    
    const newBase64Svg = Buffer.from(svg).toString('base64');
    p.wideLogo = 'data:image/svg+xml;base64,' + newBase64Svg;
    
    fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
    console.log('Successfully applied safe padding viewBox to profile.json');
} else {
    console.log('Error: SVG not found in profile.json');
}
