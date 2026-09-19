const keys = ["title", "refresh", "earlier", "loading", "empty", "load_error", "http_error", "invalid_data", "render_error"] as const;
export type Messages = Record<typeof keys[number], string>;

export function decodeMessages(input: unknown): Messages {
  if (!input || typeof input !== "object" || Array.isArray(input)) throw new Error("Invalid AgentPrism messages");
  const messages = input as Record<string, unknown>;
  for (const key of keys) {
    if (typeof messages[key] !== "string" || messages[key].length === 0) throw new Error(`Invalid AgentPrism message: ${key}`);
  }
  if (!(messages.http_error as string).includes("%{status}")) throw new Error("AgentPrism HTTP message requires %{status}");
  return messages as Messages;
}
