import { Component, useEffect, useState, type ReactNode } from "react";
import { createRoot } from "react-dom/client";
import { decodeTracePage } from "./trace-page";
import { TraceViewer, type TraceViewerData } from "../../../vendor/agent-prism/components/TraceViewer/TraceViewer";

type State = { status: "loading" } | { status: "error"; message: string } |
  { status: "ready"; data: TraceViewerData[]; nextCursor: string | null };

function App({ url }: { url: string }) {
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
        if (!response.ok) throw new Error(`Не удалось загрузить данные AgentPrism: HTTP ${response.status}`);
        const page = decodeTracePage(await response.json());
        setState({ status: "ready", ...page });
      } catch (error) {
        if (!controller.signal.aborted) setState({ status: "error", message: error instanceof Error ? error.message : "Ошибка загрузки данных AgentPrism" });
      }
    }
    void load();
    return () => controller.abort();
  }, [url, cursor, revision]);

  return <>
    <div className="ops-toolbar">
      <h1>AgentPrism</h1>
      <button onClick={() => { setCursor(null); setRevision(value => value + 1); }}>Обновить</button>
      {state.status === "ready" && state.nextCursor &&
        <button onClick={() => setCursor(state.nextCursor)}>Более ранние</button>}
    </div>
    {state.status === "loading" && <p className="ops-message" role="status">Загрузка данных AgentPrism…</p>}
    {state.status === "error" && <p className="ops-message" role="alert">{state.message}. Нажмите «Обновить».</p>}
    {state.status === "ready" && (state.data.length ?
      <div className="ops-viewer" lang="en"><TraceViewer key={`${cursor}:${revision}`} data={state.data} /></div> :
      <p className="ops-message">Пока нет данных. Они появятся после выполнения агента.</p>)}
  </>;
}

class ViewerBoundary extends Component<{ children: ReactNode }, { failed: boolean }> {
  state = { failed: false };
  static getDerivedStateFromError() { return { failed: true }; }
  render() {
    if (this.state.failed) return <p role="alert" className="ops-message">Не удалось отобразить данные AgentPrism. Обновите страницу; если ошибка повторится, проверьте контракт AgentPrism.</p>;
    return this.props.children;
  }
}

const container = document.getElementById("agent-prism");
if (!container?.dataset.url) throw new Error("Не задан адрес API AgentPrism");
createRoot(container).render(<ViewerBoundary><App url={container.dataset.url} /></ViewerBoundary>);
