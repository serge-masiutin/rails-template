/**
 * Один запрос за раз; скрытая вкладка и disconnect отменяют запрос и таймер.
 * @param {(signal: AbortSignal) => Promise<void>} refresh
 * @param {(error: unknown) => void} failed
 * @param {number} interval
 */
export function startLivePoll(refresh, failed, interval = 5000) {
  let stopped = false
  /** @type {ReturnType<typeof setTimeout> | undefined} */
  let timer
  /** @type {AbortController | null | undefined} */
  let request

  async function tick() {
    if (stopped || document.hidden || request) return
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
      if (!stopped && !document.hidden) timer = setTimeout(tick, interval)
    }
  }
  function visibilityChanged() {
    clearTimeout(timer)
    if (document.hidden) request?.abort()
    else void tick()
  }
  document.addEventListener("visibilitychange", visibilityChanged)
  void tick()
  return () => {
    stopped = true
    clearTimeout(timer)
    request?.abort()
    document.removeEventListener("visibilitychange", visibilityChanged)
  }
}
