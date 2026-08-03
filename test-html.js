const fs = require('fs');
const html = fs.readFileSync('public/index.html', 'utf8');
if (html.includes('cursor-pointer cursor-pointer')) {
  console.log('Error: duplicate cursor-pointer');
} else {
  console.log('HTML is clean');
}
