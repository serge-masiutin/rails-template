import { Controller } from "@hotwired/stimulus"
import { startLiveUpdates } from "live_updates"

export default class extends Controller {
  static targets = ["content", "status"]
  static values = { url: String, live: String, offline: String, paused: String, denied: String }

  connect() {
    this.pendingContent = null
    this.stop = startLiveUpdates("queue", signal => this.refresh(signal), () => this.status("offline"), connected => {
      this.connected = connected
      this.status(connected ? "live" : "offline")
    })
    this.resume = () => queueMicrotask(() => this.renderPending())
    this.element.addEventListener("focusout", this.resume)
    this.element.addEventListener("change", this.resume)
  }

  disconnect() {
    this.stop()
    this.pendingContent = null
    this.element.removeEventListener("focusout", this.resume)
    this.element.removeEventListener("change", this.resume)
  }

  async refresh(signal) {
    const response = await fetch(this.urlValue, { signal, credentials: "same-origin", cache: "no-store" })
    if (response.redirected || response.status === 401 || response.status === 403) {
      this.contentTarget.replaceChildren()
      this.pendingContent = null
      this.status("denied")
      this.stop()
      document.getElementById("operations-stream").remove()
      return
    }
    if (!response.ok) throw new Error(`Live update HTTP ${response.status}`)
    const parsed = new DOMParser().parseFromString(await response.text(), "text/html")
    signal.throwIfAborted()
    const content = parsed.getElementById(this.contentTarget.id)
    if (!content) throw new Error("Missing live region in response")
    this.pendingContent = content.innerHTML
    this.renderPending()
  }

  renderPending() {
    if (this.pendingContent === null) return
    // Preserve focused input and bulk-action selection while updates arrive.
    if (this.contentTarget.querySelector("input:checked") || this.contentTarget.contains(document.activeElement) && document.activeElement.matches("input, textarea, select")) {
      this.status("paused")
      return
    }
    const stream = document.createElement("turbo-stream")
    stream.setAttribute("action", "update")
    stream.setAttribute("method", "morph")
    stream.setAttribute("target", this.contentTarget.id)
    const template = document.createElement("template")
    template.innerHTML = this.pendingContent
    this.pendingContent = null
    stream.append(template)
    window.Turbo.renderStreamMessage(stream.outerHTML)
    this.status(this.connected ? "live" : "offline")
  }

  status(state) {
    this.statusTarget.textContent = this[`${state}Value`]
    this.statusTarget.dataset.state = state
  }
}
