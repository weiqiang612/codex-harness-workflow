const assert = require('node:assert/strict');
const test = require('node:test');
const { createServer } = require('../server');

test('GET /api/tasks returns the starter tasks', async (context) => {
  const server = createServer();
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  context.after(() => server.close());

  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}/api/tasks`);
  const tasks = await response.json();

  assert.equal(response.status, 200);
  assert.equal(tasks.length, 2);
  assert.deepEqual(Object.keys(tasks[0]), ['id', 'title']);
});
