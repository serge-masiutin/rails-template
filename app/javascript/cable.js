import { createCable } from "@anycable/web"
import { start, TurboChannel } from "@anycable/turbo-stream"

const cable = createCable({ protocol: "actioncable-v1-ext-json" })

class RecoverableTurboChannel extends TurboChannel {
  constructor(...args) {
    super(...args)
    this.on("info", ({ type }) => {
      // Fetch fresh HTML after the recovery history expires.
      if (type === "history_not_found") window.location.reload()
    })
  }
}

start(cable, { channelClass: RecoverableTurboChannel, delayedUnsubscribe: true })

export default cable
