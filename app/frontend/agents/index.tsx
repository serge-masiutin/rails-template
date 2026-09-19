import { startLiveUpdates } from "../../javascript/live_updates.js";
import { Component, useEffect, useState, type ReactNode } from "react";
import { createRoot } from "react-dom/client";
import { decodeMessages, type Messages } from "./messages";
import { InvalidTracePage, decodeTracePage } from "./trace-page";
import { TraceViewer, type TraceViewerData } from "../../../vendor/agent-prism/components/TraceViewer/TraceViewer";

type State = { status: "loading" } | { status: "error"; message: string } |
  { status: "ready"; data: TraceViewerData[]; nextCursor: string | null };

function App({ url, messages }: { url: string; messages: Messages }) {
  const [cursor, setCursor] = useState<string | null>(null);
  const [state, setState] = useState<State>({ status: "loading" });
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  useEffect(() => {
    setState({ status: "loading" });
    setError(null);
    let previous = "";
    const stop = startLiveUpdates("agents", async (signal: AbortSignal) => {
      const endpoint = new URL(url, window.location.origin);
      if (cursor) endpoint.searchParams.set("before", cursor);
      const response = await fetch(endpoint, { signal, credentials: "same-origin", cache: "no-store" });
      if (response.redirected || response.status === 401 || response.status === 403) {
        setState({ status: "error", message: messages.denied });
        setError(null);
        stop();
        document.getElementById("operations-stream")!.remove();
        return;
      }
      if (!response.ok) throw new HttpError(response.status);
      const payload = await response.json();
      signal.throwIfAborted();
      const page = decodeTracePage(payload);
      const fingerprint = JSON.stringify(payload);
      if (previous !== fingerprint) setState({ status: "ready", ...page });
      previous = fingerprint;
      setError(null);
    }, (failure: unknown) => {
      setError(failure instanceof InvalidTracePage ? messages.invalid_data :
        failure instanceof HttpError ? messages.http_error.replace("%{status}", String(failure.status)) : messages.load_error);
    }, setConnected);
    return stop;
  }, [url, cursor, messages]);

  return <>
    <div className="ops-toolbar">
      <h1>{messages.title}</h1>
      {state.status !== "error" && <span className="admin-live" role="status" data-state={error || !connected ? "offline" : "live"}>{error || !connected ? messages.offline : messages.live}</span>}
      <div className="ops-pagination">
        {cursor && <button onClick={() => setCursor(null)}>{messages.latest}</button>}
        {state.status === "ready" && state.nextCursor &&
          <button onClick={() => setCursor(state.nextCursor)}>{messages.earlier}</button>}
      </div>
    </div>
    {error && <p className="ops-message" role="alert">{error}</p>}
    {state.status === "loading" && !error && <p className="ops-message" role="status">{messages.loading}</p>}
    {state.status === "error" && <p className="ops-message" role="alert">{state.message}</p>}
    {state.status === "ready" && (state.data.length ?
      <div className="ops-viewer" lang="en"><TraceViewer key={cursor ?? "latest"} data={state.data} /></div> :
      <p className="ops-message">{messages.empty}</p>)}
  </>;
}

class HttpError extends Error {
  constructor(public status: number) { super(`HTTP ${status}`); }
}

class ViewerBoundary extends Component<{ children: ReactNode; message: string }, { failed: boolean }> {
  state = { failed: false };
  static getDerivedStateFromError() { return { failed: true }; }
  render() {
    if (this.state.failed) return <p role="alert" className="ops-message">{this.props.message}</p>;
    return this.props.children;
  }
}

const container = document.getElementById("agent-prism");
if (!container?.dataset.url || !container.dataset.messages) throw new Error("Missing AgentPrism configuration");
const messages = decodeMessages(JSON.parse(container.dataset.messages));
createRoot(container).render(<ViewerBoundary message={messages.render_error}><App url={container.dataset.url} messages={messages} /></ViewerBoundary>);
