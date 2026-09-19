import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content"]

  toggle() {
    const expanded = this.buttonTarget.getAttribute("aria-expanded") === "true"
    this.buttonTarget.setAttribute("aria-expanded", String(!expanded))
    this.contentTarget.hidden = expanded
  }
}
