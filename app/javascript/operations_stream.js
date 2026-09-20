import "cable"
import { StreamActions } from "@hotwired/turbo"

// Only invalidation signals travel over the shared admin stream.
StreamActions.operations_refresh = function () {
  document.dispatchEvent(new CustomEvent("operations:refresh", { detail: { topic: this.getAttribute("topic") } }))
}
