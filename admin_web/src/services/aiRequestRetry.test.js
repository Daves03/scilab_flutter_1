import test from 'node:test';
import assert from 'node:assert/strict';
import { isTemporaryAiError, retryTemporaryAiRequest } from './aiRequestRetry.js';

test('high-demand failures are retried with increasing delays and can recover', async () => {
  let calls = 0;
  const delays = [];
  const result = await retryTemporaryAiRequest(async () => {
    if (++calls < 3) throw Object.assign(new Error('This model is currently experiencing high demand.'), { status: 503 });
    return 'quiz';
  }, { wait: async (delay) => delays.push(delay) });
  assert.equal(result, 'quiz');
  assert.equal(calls, 3);
  assert.deepEqual(delays, [2000, 4000]);
});

test('retries stop after two retries when the provider stays busy', async () => {
  let calls = 0;
  await assert.rejects(retryTemporaryAiRequest(async () => {
    calls++;
    throw Object.assign(new Error('Busy'), { status: 503 });
  }, { wait: async () => {} }), /Busy/);
  assert.equal(calls, 3);
});

test('does not retry authentication or quota failures', async () => {
  for (const status of [400, 401, 403, 429]) {
    let calls = 0;
    await assert.rejects(retryTemporaryAiRequest(async () => {
      calls++;
      throw Object.assign(new Error('Rejected'), { status });
    }));
    assert.equal(calls, 1);
  }
  assert.equal(isTemporaryAiError(new Error('This model is currently experiencing high demand.')), true);
});

test('cancellation during backoff prevents another request', async () => {
  const controller = new AbortController();
  let calls = 0;
  await assert.rejects(retryTemporaryAiRequest(async () => {
    calls++;
    throw Object.assign(new Error('Busy'), { status: 503 });
  }, { signal: controller.signal, wait: async () => controller.abort() }), { name: 'AbortError' });
  assert.equal(calls, 1);
});

test('honors Retry-After up to the bounded wait limit', async () => {
  let calls = 0;
  const delays = [];
  await retryTemporaryAiRequest(async () => {
    if (++calls === 1) throw Object.assign(new Error('Busy'), { status: 503, retryAfterMs: 12000 });
  }, { wait: async (delay) => delays.push(delay) });
  assert.deepEqual(delays, [12000]);
});
