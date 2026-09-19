import { Component, useEffect, useState, type ReactNode } from "react";
import { createRoot } from "react-dom/client";
import { decodeMessages, type Messages } from "./messages";
import { InvalidTracePage, decodeTracePage } from "./trace-page";
import { TraceViewer, type TraceViewerData } from "../../../vendor/agent-prism/components/TraceViewer/TraceViewer";

type State = { status: "loading" } | { status: "error"; message: string } |
  { status: "ready"; data: TraceViewerData[]; nextCursor: string | null };

function App({ url, messages }: { url: string; messages: Messages }) {
  const [cursor, setCursor] = useState<string | null>(null);
  const [revision, setRevision] = useState(0);
  const [state, setState] = useState<State>({ status: "loading" });
  useEffect(() => {
    const controller = new AbortController();
    setState({ status: "loading" });
    async function load() {
      try {
        const endpoint = new URL(url, window.location.origin);
        if (cursor) endpoint.searchParams.set("before", cursor);
        const response = await fetch(endpoint, { signal: controller.signal, credentials: "same-origin", cache: "no-store" });
        if (!response.ok) {
          setState({ status: "error", message: messages.http_error.replace("%{status}", String(response.status)) });
          return;
        }
        const page = decodeTracePage(await response.json());
        setState({ status: "ready", ...page });
      } catch (error) {
        if (!controller.signal.aborted) setState({ status: "error", message: error instanceof InvalidTracePage ? messages.invalid_data : messages.load_error });
      }
    }
    void load();
    return () => controller.abort();
  }, [url, cursor, revision, messages]);

  return <>
    <div className="ops-toolbar">
      <h1>{messages.title}</h1>
      <button onClick={() => { setCursor(null); setRevision(value => value + 1); }}>{messages.refresh}</button>
      {state.status === "ready" && state.nextCursor &&
        <button onClick={() => setCursor(state.nextCursor)}>{messages.earlier}</button>}
    </div>
    {state.status === "loading" && <p className="ops-message" role="status">{messages.loading}</p>}
    {state.status === "error" && <p className="ops-message" role="alert">{state.message}</p>}
    {state.status === "ready" && (state.data.length ?
      <div className="ops-viewer" lang="en"><TraceViewer key={`${cursor}:${revision}`} data={state.data} /></div> :
      <p className="ops-message">{messages.empty}</p>)}
  </>;
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
