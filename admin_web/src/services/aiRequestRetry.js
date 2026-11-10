export const isTemporaryAiError = (error) => {
  if (Number.isFinite(error?.status)) return [500, 502, 503, 504].includes(error.status);
  const message = String(error?.message || error).toLowerCase();
  if (/quota|429|api key|payment/.test(message)) return false;
  return /high demand|overloaded|temporarily unavailable|service unavailable|\b50[0234]\b/.test(message);
};

const waitForRetry = (delay, signal) => new Promise((resolve, reject) => {
  signal?.throwIfAborted();
  const cancel = () => { clearTimeout(timer); reject(signal.reason || new DOMException('Cancelled', 'AbortError')); };
  const timer = setTimeout(() => { signal?.removeEventListener('abort', cancel); resolve(); }, delay);
  signal?.addEventListener('abort', cancel, { once: true });
});

export async function retryTemporaryAiRequest(request, { signal, onRetry = () => {}, wait = waitForRetry } = {}) {
  for (let attempt = 0; ; attempt++) {
    signal?.throwIfAborted();
    try { return await request(); } catch (error) {
      if (signal?.aborted || attempt >= 2 || !isTemporaryAiError(error)) throw error;
      const delay = Math.min(30000, Math.max(2000 * (2 ** attempt), error.retryAfterMs || 0));
      onRetry(attempt + 1, delay);
      await wait(delay, signal);
    }
  }
}
