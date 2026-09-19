/**
 * AnyCable delivers invalidation signals; HTTP rechecks access and fetches a snapshot.
 * Coalesce event batches without an idle polling timer. Bound each request with a timeout.
 * @param {string} topic
 * @param {(signal: AbortSignal) => Promise<void>} refresh
 * @param {(error: unknown) => void} failed
 * @param {(connected: boolean) => void} connectionChanged
 */
export function startLiveUpdates(topic, refresh, failed, connectionChanged) {
  const source = document.getElementById("operations-stream")
  if (!source) throw new Error("Missing operations stream")
  let stopped = false
  let pending = false
  /** @type {ReturnType<typeof setTimeout> | undefined} */
  let timer
  /** @type {AbortController | null} */
  let request = null

  function schedule() {
    if (stopped || document.hidden || request || timer !== undefined || !pending) return
    timer = setTimeout(run, 250)
  }
  function invalidate() {
    pending = true
    schedule()
  }
  async function run() {
    timer = undefined
    pending = false
    const controller = new AbortController()
    request = controller
    const timeout = setTimeout(() => controller.abort(new Error("Live update timed out")), 10000)
    try {
      await refresh(controller.signal)
    } catch (error) {
      if (!stopped && !document.hidden) failed(error)
    } finally {
      clearTimeout(timeout)
      request = null
      schedule()
    }
  }
  /** @param {Event} event */
  function changed(event) {
    const changedTopic = /** @type {CustomEvent<{ topic: string }>} */ (event).detail.topic
    if (changedTopic === topic || changedTopic === "access") invalidate()
  }
  function visibilityChanged() {
    if (document.hidden) {
      clearTimeout(timer)
      timer = undefined
      request?.abort()
    } else invalidate()
  }
  const observer = new MutationObserver(() => {
    connectionChanged(source.hasAttribute("connected"))
    // Reconnect fetches missed changes; disconnect checks whether the session was revoked.
    invalidate()
  })
  observer.observe(source, { attributes: true, attributeFilter: ["connected"] })
  connectionChanged(source.hasAttribute("connected"))
  document.addEventListener("operations:refresh", changed)
  document.addEventListener("visibilitychange", visibilityChanged)
  invalidate()
  return () => {
    stopped = true
    clearTimeout(timer)
    request?.abort()
    observer.disconnect()
    document.removeEventListener("operations:refresh", changed)
    document.removeEventListener("visibilitychange", visibilityChanged)
  }
}
