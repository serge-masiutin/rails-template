import type { TraceSpan, TraceRecord } from "@evilmartians/agent-prism-types";
import type { TraceViewerData } from "../../../vendor/agent-prism/components/TraceViewer/TraceViewer";

const categories = new Set(["agent_invocation", "chain_operation", "llm_call", "tool_execution", "span", "embedding", "event"]);
const statuses = new Set(["success", "error", "pending", "warning"]);
const invalid = () => new Error("Некорректный формат данных AgentPrism");
function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) throw invalid();
  return value as Record<string, unknown>;
}
function string(value: unknown): string {
  if (typeof value !== "string") throw invalid();
  return value;
}
function number(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0) throw invalid();
  return value;
}
function integer(value: unknown): number {
  const parsed = number(value);
  if (!Number.isSafeInteger(parsed)) throw invalid();
  return parsed;
}
function array(value: unknown): unknown[] {
  if (!Array.isArray(value)) throw invalid();
  return value;
}
function date(value: unknown): Date {
  const parsed = new Date(string(value));
  if (!Number.isFinite(parsed.getTime())) throw invalid();
  return parsed;
}
function span(input: unknown, depth: number, count: { value: number }): TraceSpan {
  if (depth >= 32 || ++count.value > 256) throw invalid();
  const source = object(input);
  const type = string(source.type);
  const status = string(source.status);
  if (!categories.has(type) || !statuses.has(status)) throw invalid();
  const startTime = date(source.startTime), endTime = date(source.endTime);
  if (endTime < startTime) throw invalid();
  return {
    id: string(source.id), title: string(source.title), raw: string(source.raw),
    type: type as TraceSpan["type"], status: status as TraceSpan["status"],
    startTime, endTime, duration: number(source.duration),
    ...(source.tokensCount === undefined ? {} : { tokensCount: integer(source.tokensCount) }),
    attributes: array(source.attributes).map(input => {
      const attribute = object(input);
      return { key: string(attribute.key), value: { stringValue: string(object(attribute.value).stringValue) } };
    }),
    children: array(source.children).map(child => span(child, depth + 1, count)),
  };
}
export function decodeTracePage(input: unknown): { data: TraceViewerData[]; nextCursor: string | null } {
  const page = object(input);
  if (page.version !== 1) throw invalid();
  const nextCursor = page.next_cursor === null ? null : string(page.next_cursor);
  if (nextCursor !== null && !/^[1-9][0-9]{0,18}$/.test(nextCursor)) throw invalid();
  const traces = array(page.data);
  if (traces.length > 20) throw invalid();
  const data = traces.map(input => {
    const trace = object(input), record = object(trace.traceRecord);
    const traceRecord: TraceRecord = {
      id: string(record.id), name: string(record.name), agentDescription: string(record.agentDescription),
      spansCount: integer(record.spansCount), durationMs: number(record.durationMs), startTime: number(record.startTime),
      ...(record.totalTokens === undefined ? {} : { totalTokens: integer(record.totalTokens) }),
    };
    const count = { value: 0 };
    const spans = array(trace.spans).map(child => span(child, 0, count));
    if (spans.length !== 1 || count.value !== traceRecord.spansCount) throw invalid();
    return { traceRecord, spans };
  });
  return { data, nextCursor };
}
