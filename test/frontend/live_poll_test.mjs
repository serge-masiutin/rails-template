import { test } from "node:test";
import assert from "node:assert/strict";
import { setImmediate } from "node:timers/promises";
import { startLivePoll } from "../../app/javascript/live_poll.js";

function setup(t) {
  const document = new EventTarget();
  document.hidden = false;
  globalThis.document = document;
  t.mock.timers.enable({ apis: ["setTimeout"] });
  return document;
}

test("poll не перекрывает запросы и прекращает работу после disconnect", async t => {
  setup(t);
  let complete;
  let calls = 0;
  let signal;
  const stop = startLivePoll(value => {
    calls++;
    signal = value;
    return new Promise(resolve => { complete = resolve; });
  }, assert.fail);
  t.after(() => { stop(); delete globalThis.document; });
  t.mock.timers.tick(5000);
  assert.equal(calls, 1);
  complete();
  await setImmediate();
  t.mock.timers.tick(5000);
  assert.equal(calls, 2);
  stop();
  assert.equal(signal.aborted, true);
  complete();
  await setImmediate();
  t.mock.timers.tick(60000);
  assert.equal(calls, 2);
});

test("скрытая вкладка не опрашивается; возвращение возобновляет обновления", async t => {
  const document = setup(t);
  document.hidden = true;
  let calls = 0;
  const stop = startLivePoll(async () => { calls++; }, assert.fail);
  t.after(() => { stop(); delete globalThis.document; });
  t.mock.timers.tick(20000);
  assert.equal(calls, 0);
  document.hidden = false;
  document.dispatchEvent(new Event("visibilitychange"));
  await setImmediate();
  assert.equal(calls, 1);
  document.hidden = true;
  document.dispatchEvent(new Event("visibilitychange"));
  t.mock.timers.tick(20000);
  assert.equal(calls, 1);
});

test("таймаут показывает сбой, следующий poll восстанавливает соединение", async t => {
  setup(t);
  const failures = [];
  let calls = 0;
  const stop = startLivePoll(signal => {
    calls++;
    return new Promise((_resolve, reject) => signal.addEventListener("abort", () => reject(signal.reason)));
  }, error => failures.push(error));
  t.after(() => { stop(); delete globalThis.document; });
  t.mock.timers.tick(10000);
  await setImmediate();
  assert.equal(failures.length, 1);
  assert.match(failures[0].message, /timed out/);
  t.mock.timers.tick(5000);
  assert.equal(calls, 2);
});
