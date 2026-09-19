import { createCable } from "@anycable/web"
import { start, TurboChannel } from "@anycable/turbo-stream"

const cable = createCable({ protocol: "actioncable-v1-ext-json" })

class RecoverableTurboChannel extends TurboChannel {
  constructor(...args) {
    super(...args)
    this.on("info", ({ type }) => {
      // После истечения истории получаем актуальный HTML с сервера.
      if (type === "history_not_found") window.location.reload()
    })
  }
}

start(cable, { channelClass: RecoverableTurboChannel, delayedUnsubscribe: true })

export default cable
