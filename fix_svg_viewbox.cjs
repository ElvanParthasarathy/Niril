const fs = require('fs');

const profilePath = 'tharavu/profile.json';
const p = JSON.parse(fs.readFileSync(profilePath));
let svgDataUri = p.wideLogo;

if (svgDataUri.startsWith('data:image/svg+xml;base64,')) {
    let base64Svg = svgDataUri.replace('data:image/svg+xml;base64,', '');
    let svg = Buffer.from(base64Svg, 'base64').toString('utf8');
    
    // Replace the giant viewBox with one that tightly crops around the actual artwork
    // The artwork paths are roughly from X=930 to X=1680 (width 750)
    // and Y=650 to Y=780 (height 130)
    svg = svg.replace('viewBox="0 0 2560 1440"', 'viewBox="930 650 760 130"');
    
    // We also need to remove the giant empty rect that Illustrator added: <rect width="2560" height="1440" fill="none"/>
    svg = svg.replace('<rect width="2560" height="1440" fill="none"/>', '');
    
    const newBase64Svg = Buffer.from(svg).toString('base64');
    p.wideLogo = 'data:image/svg+xml;base64,' + newBase64Svg;
    
    fs.writeFileSync(profilePath, JSON.stringify(p, null, 2));
    console.log('Successfully cropped the SVG and updated profile.json');
} else {
    console.log('Error: SVG not found in profile.json');
}
