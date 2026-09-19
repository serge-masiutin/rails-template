import "cable"
import { StreamActions } from "@hotwired/turbo"

// Public Turbo API: the shared admin stream carries no panel data.
StreamActions.operations_refresh = function () {
  document.dispatchEvent(new CustomEvent("operations:refresh", { detail: { topic: this.getAttribute("topic") } }))
}
