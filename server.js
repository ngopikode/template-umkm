const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;

const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'application/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.webp': 'image/webp'
};

const server = http.createServer((req, res) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);

    // Clean up request URL path
    let filePath = req.url === '/' ? '/index.html' : req.url;
    const publicPath = path.join(__dirname, 'public');
    filePath = path.join(publicPath, filePath);

    // Safeguard against directory traversal attacks
    if (!filePath.startsWith(publicPath)) {
        res.statusCode = 403;
        res.setHeader('Content-Type', 'text/plain');
        res.end('Access Denied');
        return;
    }

    const extname = path.extname(filePath).toLowerCase();
    let contentType = MIME_TYPES[extname] || 'application/octet-stream';

    fs.stat(filePath, (err, stats) => {
        if (err) {
            if (err.code === 'ENOENT') {
                // If it's a directory, check for index.html inside it
                fs.stat(path.join(filePath, 'index.html'), (subErr, subStats) => {
                    if (!subErr && subStats.isFile()) {
                        filePath = path.join(filePath, 'index.html');
                        contentType = 'text/html';
                        serveFile(filePath, contentType, res);
                    } else {
                        // Return 404 page
                        serve404(res);
                    }
                });
            } else {
                res.statusCode = 500;
                res.setHeader('Content-Type', 'text/plain');
                res.end(`Server Error: ${err.code}`);
            }
            return;
        }

        if (stats.isDirectory()) {
            filePath = path.join(filePath, 'index.html');
            contentType = 'text/html';
        }

        serveFile(filePath, contentType, res);
    });
});

function serveFile(filePath, contentType, res) {
    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.statusCode = 500;
            res.setHeader('Content-Type', 'text/plain');
            res.end(`Error reading file: ${err.code}`);
            return;
        }
        res.statusCode = 200;
        res.setHeader('Content-Type', contentType);
        res.end(data);
    });
}

function serve404(res) {
    const errorPagePath = path.join(__dirname, 'public', '404.html');
    fs.readFile(errorPagePath, (err, data) => {
        res.statusCode = 404;
        res.setHeader('Content-Type', 'text/html');
        if (!err) {
            res.end(data);
        } else {
            res.end(`
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <title>404 Not Found</title>
                    <style>
                        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; text-align: center; padding: 50px; background: #0b0f19; color: #f3f4f6; }
                        h1 { color: #f3f4f6; font-size: 40px; margin-bottom: 10px; }
                        p { color: #9ca3af; font-size: 18px; }
                        a { color: #d4af37; text-decoration: none; font-weight: bold; }
                        a:hover { text-decoration: underline; }
                    </style>
                </head>
                <body>
                    <h1>404</h1>
                    <p>Oops! The page you are looking for does not exist.</p>
                    <p><a href="/">Return to Showcase Portal</a></p>
                </body>
                </html>
            `);
        }
    });
}

server.listen(PORT, () => {
    console.log("==================================================");
    console.log("  Server is running at: http://localhost:" + PORT);
    console.log("==================================================");
    console.log("Press Ctrl+C to stop.");
});
