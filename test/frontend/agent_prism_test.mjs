import { test } from "node:test";
import assert from "node:assert/strict";
import { decodeTracePage } from "../../app/frontend/agents/trace-page.ts";

function page() {
  return { version: 1, next_cursor: null, data: [{
    traceRecord: { id: "trace", name: "Probe.run", agentDescription: "Active Agent", durationMs: 10, spansCount: 1, startTime: 1 },
    spans: [{ id: "span", title: "Probe.run", type: "agent_invocation", status: "success", raw: "{}", duration: 10,
      startTime: "2026-09-19T01:00:00Z", endTime: "2026-09-19T01:00:00.010Z", children: [], attributes: [] }],
  }] };
}
test("Даты декодируются, отсутствующий usage остаётся неизвестным", () => {
  const decoded = decodeTracePage(page());
  assert.ok(decoded.data[0].spans[0].startTime instanceof Date);
  assert.equal(decoded.data[0].traceRecord.totalTokens, undefined);
});
test("Нарушение версии, структуры или числового контракта отклоняется", () => {
  const mutations = [
    value => { value.version = 2; },
    value => { value.next_cursor = "bad"; },
    value => { delete value.data[0].traceRecord.name; },
    value => { value.data[0].traceRecord.totalTokens = "42"; },
    value => { value.data[0].spans[0].startTime = "bad"; },
    value => { value.data[0].spans[0].type = "new_type"; },
    value => { value.data[0].spans[0].children = null; },
    value => { value.data[0].spans[0].duration = -1; },
  ];
  for (const mutate of mutations) { const payload = page(); mutate(payload); assert.throws(() => decodeTracePage(payload), /Invalid AgentPrism data format/); }
});

test("AgentPrism принимает полный словарь и отклоняет неполные переводы", async () => {
  const { decodeMessages } = await import("../../app/frontend/agents/messages.ts");
  const messages = Object.fromEntries(["title", "refresh", "earlier", "loading", "empty", "load_error", "http_error", "invalid_data", "render_error"].map(key => [key, key === "http_error" ? "HTTP %{status}" : key]));
  assert.equal(decodeMessages(messages).refresh, "refresh");
  assert.throws(() => decodeMessages({ ...messages, refresh: undefined }), /refresh/);
  assert.throws(() => decodeMessages({ ...messages, http_error: "HTTP" }), /status/);
  assert.throws(() => decodeMessages([]), /Invalid/);
});
