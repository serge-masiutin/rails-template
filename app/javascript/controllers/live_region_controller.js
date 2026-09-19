import { Controller } from "@hotwired/stimulus"
import { startLivePoll } from "live_poll"

export default class extends Controller {
  static targets = ["content", "status"]
  static values = { url: String, live: String, offline: String, paused: String, denied: String }

  connect() {
    this.stop = startLivePoll(signal => this.refresh(signal), () => this.status("offline"))
  }

  disconnect() { this.stop() }

  async refresh(signal) {
    const response = await fetch(this.urlValue, { signal, credentials: "same-origin", cache: "no-store" })
    if (response.redirected || response.status === 401 || response.status === 403) {
      this.contentTarget.replaceChildren()
      this.status("denied")
      this.stop()
      return
    }
    if (!response.ok) throw new Error(`Live update HTTP ${response.status}`)
    // Не прерываем набор текста и выбор заданий для массового действия.
    if (this.contentTarget.querySelector("input:checked") || this.contentTarget.contains(document.activeElement) && document.activeElement.matches("input, textarea, select")) {
      this.status("paused")
      return
    }
    const parsed = new DOMParser().parseFromString(await response.text(), "text/html")
    signal.throwIfAborted()
    const content = parsed.getElementById(this.contentTarget.id)
    if (!content) throw new Error("Missing live region in response")
    const stream = document.createElement("turbo-stream")
    stream.setAttribute("action", "update")
    stream.setAttribute("method", "morph")
    stream.setAttribute("target", this.contentTarget.id)
    const template = document.createElement("template")
    template.innerHTML = content.innerHTML
    stream.append(template)
    window.Turbo.renderStreamMessage(stream.outerHTML)
    this.status("live")
  }

  status(state) {
    this.statusTarget.textContent = this[`${state}Value`]
    this.statusTarget.dataset.state = state
  }
}
