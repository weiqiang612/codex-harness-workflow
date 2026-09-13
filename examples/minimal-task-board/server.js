const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const tasks = [
  { id: 1, title: 'Read the project map' },
  { id: 2, title: 'Review the feature contract' },
];

function createServer() {
  return http.createServer((request, response) => {
    if (request.method === 'GET' && request.url === '/api/tasks') {
      response.writeHead(200, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify(tasks));
      return;
    }

    if (request.method === 'GET' && (request.url === '/' || request.url === '/index.html')) {
      const html = fs.readFileSync(path.join(__dirname, 'public', 'index.html'));
      response.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      response.end(html);
      return;
    }

    response.writeHead(404, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ error: 'Not found' }));
  });
}

if (require.main === module) {
  createServer().listen(3000, () => {
    console.log('Minimal task board listening on http://localhost:3000');
  });
}

module.exports = { createServer };
