import http from "k6/http"
import { check, fail, sleep } from "k6"
import { WebSocket } from "k6/websockets"
import { setTimeout, clearTimeout } from "k6/timers"
import { Counter, Trend } from "k6/metrics"

const baseURL = __ENV.LOAD_BASE_URL
const cableURL = __ENV.LOAD_CABLE_URL
const profile = __ENV.LOAD_PROFILE
const profiles = {
  smoke: { http: 1, sockets: 2, duration: "8s", hold: 4000 },
  load: { http: 5, sockets: 20, duration: "30s", hold: 10000 }
}
if (!profiles[profile] || !baseURL || !cableURL || !__ENV.LOAD_EMAIL || !__ENV.LOAD_PASSWORD) {
  throw new Error("Set LOAD_PROFILE=smoke|load, LOAD_BASE_URL, LOAD_CABLE_URL and test credentials")
}
const selected = profiles[profile]
const deliveries = new Counter("turbo_deliveries")
const deliveryLatency = new Trend("turbo_delivery_ms", true)
const subscriptionLatency = new Trend("cable_subscription_ms", true)
const socketErrors = new Counter("cable_errors")

export const options = {
  scenarios: {
    pages: { executor: "constant-vus", exec: "pages", vus: selected.http, duration: selected.duration },
    cable: { executor: "constant-vus", exec: "cable", vus: selected.sockets, duration: selected.duration }
  },
  thresholds: {
    checks: ["rate==1"],
    http_req_failed: ["rate==0"],
    "http_req_duration{page:workspace}": ["p(95)<2000"],
    "http_req_duration{page:account}": ["p(95)<2000"],
    cable_errors: ["count==0"],
    cable_subscription_ms: ["p(95)<2000"],
    turbo_deliveries: ["count>0"],
    turbo_delivery_ms: ["p(95)<2000"]
  }
}

export function setup() {
  const form = http.get(`${baseURL}/session/new`)
  const csrf = form.html().find('input[name="authenticity_token"]').attr("value")
  if (form.status !== 200 || !csrf) fail("Sign-in form or CSRF token missing")
  const login = http.post(`${baseURL}/session`, {
    email_address: __ENV.LOAD_EMAIL, password: __ENV.LOAD_PASSWORD, authenticity_token: csrf
  }, { redirects: 0 })
  if (login.status !== 303) fail(`Sign-in: expected 303, received ${login.status}`)
  const page = http.get(`${baseURL}/`)
  const stream = page.html().find('turbo-cable-stream-source[channel="UserUpdatesChannel"]').attr("signed-stream-name")
  const cookies = http.cookieJar().cookiesForURL(baseURL)
  if (page.status !== 200 || !stream || !cookies.session_id) fail("Private subscription and session cookie missing")
  return { cookie: `session_id=${cookies.session_id[0]}`, stream }
}

export function pages(session) {
  for (const [path, page, selector] of [["/", "workspace", "turbo-cable-stream-source"], ["/account", "account", "#main"]]) {
    const response = http.get(`${baseURL}${path}`, {
      headers: { Cookie: session.cookie }, redirects: 0, tags: { page }
    })
    check(response, {
      "page is accessible after sign-in": (result) => result.status === 200,
      "page contains the expected element": (result) => result.html().find(selector).size() > 0
    })
  }
  sleep(1)
}

export function cable(session) {
  const started = Date.now()
  const identifier = JSON.stringify({ channel: "UserUpdatesChannel", signed_stream_name: session.stream })
  const socket = new WebSocket(cableURL, [], { headers: { Cookie: session.cookie, Origin: baseURL } })
  let subscribed = false
  let received = 0
  let closeRequested = false
  socketErrors.add(0)
  const deadline = setTimeout(() => {
    closeRequested = true
    socket.close()
  }, selected.hold)

  socket.addEventListener("message", (event) => {
    const frame = JSON.parse(event.data)
    if (frame.type === "welcome") socket.send(JSON.stringify({ command: "subscribe", identifier }))
    if (frame.type === "confirm_subscription" && frame.identifier === identifier) {
      subscribed = true
      subscriptionLatency.add(Date.now() - started)
    }
    if (frame.type === "reject_subscription" || frame.type === "disconnect") {
      socketErrors.add(1)
    }
    if (frame.identifier === identifier && typeof frame.message === "string") {
      const timestamp = frame.message.match(/data-load-published-at="(\d+)"/)
      if (timestamp) {
        received += 1
        deliveries.add(1)
        deliveryLatency.add(Date.now() - Number(timestamp[1]))
      }
    }
  })
  socket.addEventListener("error", () => socketErrors.add(1))
  socket.addEventListener("close", () => {
    clearTimeout(deadline)
    check(null, {
      "connection lasts until the interval ends": () => closeRequested,
      "private subscription is confirmed": () => subscribed,
      "Turbo Stream is delivered through the socket": () => received > 0
    })
    sleep(1)
  })
}
