const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));
let svgDataUri = p.wideLogo;

if (svgDataUri.startsWith('data:image/svg+xml;base64,')) {
    let base64Svg = svgDataUri.replace('data:image/svg+xml;base64,', '');
    let svg = Buffer.from(base64Svg, 'base64').toString('utf8');
    
    // I calculated the exact bezier curves this time. 
    // The shuttle goes left to X=870. The hand goes up to Y=530.
    // So MinX=800, MinY=500 is completely safe.
    // Width=1000, Height=350 is an exact 2.85 aspect ratio which perfectly matches our 400x140 container!
    svg = svg.replace(/viewBox="[^"]+"/, 'viewBox="800 500 1000 350"');
    
    const newBase64Svg = Buffer.from(svg).toString('base64');
    p.wideLogo = 'data:image/svg+xml;base64,' + newBase64Svg;
    
    fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
    console.log('Successfully applied perfect 1000x350 viewBox to profile.json');
} else {
    console.log('Error: SVG not found in profile.json');
}
