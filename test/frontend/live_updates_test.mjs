import { test } from "node:test";
import assert from "node:assert/strict";
import { setImmediate } from "node:timers/promises";
import { startLiveUpdates } from "../../app/javascript/live_updates.js";

function setup(t) {
  const document = new EventTarget();
  document.hidden = false;
  document.getElementById = () => ({ hasAttribute: () => true });
  globalThis.document = document;
  let observer;
  globalThis.MutationObserver = class {
    constructor(callback) { observer = callback; }
    observe() {}
    disconnect() { observer = () => {}; }
  };
  t.mock.timers.enable({ apis: ["setTimeout"] });
  return {
    document,
    signal: (topic = "queue") => document.dispatchEvent(new CustomEvent("operations:refresh", { detail: { topic } })),
    reconnect: () => observer(),
    flush: async () => { t.mock.timers.tick(250); await setImmediate(); }
  };
}

test("events coalesce with no idle or post-disconnect requests", async t => {
  const { signal, flush } = setup(t);
  let calls = 0;
  const stop = startLiveUpdates("queue", async () => { calls++; }, assert.fail, () => {});
  t.after(() => { stop(); delete globalThis.document; delete globalThis.MutationObserver; });
  await flush();
  assert.equal(calls, 1);
  t.mock.timers.tick(60000);
  await setImmediate();
  assert.equal(calls, 1);
  signal("agents");
  await flush();
  assert.equal(calls, 1);
  for (let i = 0; i < 10; i++) signal();
  await flush();
  assert.equal(calls, 2);
  signal("access");
  await flush();
  assert.equal(calls, 3);
  stop();
  signal();
  await flush();
  assert.equal(calls, 3);
});

test("an event during a request is retained without concurrent fetches", async t => {
  const { signal, flush } = setup(t);
  let complete;
  let calls = 0;
  let requestSignal;
  const stop = startLiveUpdates("queue", value => {
    calls++;
    requestSignal = value;
    return new Promise(resolve => { complete = resolve; });
  }, assert.fail, () => {});
  t.after(() => { stop(); delete globalThis.document; delete globalThis.MutationObserver; });
  await flush();
  signal();
  await flush();
  assert.equal(calls, 1);
  complete();
  await setImmediate();
  await flush();
  assert.equal(calls, 2);
  stop();
  assert.equal(requestSignal.aborted, true);
  complete();
});

test("hidden tabs stop HTTP and refresh on visibility return or reconnect", async t => {
  const { document, signal, reconnect, flush } = setup(t);
  document.hidden = true;
  let calls = 0;
  const stop = startLiveUpdates("agents", async () => { calls++; }, assert.fail, () => {});
  t.after(() => { stop(); delete globalThis.document; delete globalThis.MutationObserver; });
  signal("agents");
  await flush();
  assert.equal(calls, 0);
  document.hidden = false;
  document.dispatchEvent(new Event("visibilitychange"));
  await flush();
  assert.equal(calls, 1);
  reconnect();
  await flush();
  assert.equal(calls, 2);
});

test("timeout is visible and another request requires a new event", async t => {
  const { signal, flush } = setup(t);
  let calls = 0;
  const failures = [];
  const stop = startLiveUpdates("queue", abort => {
    calls++;
    return new Promise((_resolve, reject) => abort.addEventListener("abort", () => reject(abort.reason)));
  }, error => failures.push(error), () => {});
  t.after(() => { stop(); delete globalThis.document; delete globalThis.MutationObserver; });
  await flush();
  t.mock.timers.tick(10000);
  await setImmediate();
  assert.match(failures[0].message, /timed out/);
  t.mock.timers.tick(60000);
  assert.equal(calls, 1);
  signal();
  await flush();
  assert.equal(calls, 2);
});
