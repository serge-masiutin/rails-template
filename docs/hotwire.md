# Forms and navigation

Rails returns shared HTML for web and Android. Turbo Drive is loaded by the layout;
Stimulus controllers live in `app/javascript/controllers`.

## HTTP contract

- GET returns a page or Turbo Frame. Successful mutations redirect with 303.
- Invalid forms return HTML with 422; missing required parameters return 400 through `params.expect`.
- Mutate through forms and `button_to`; read through links. Keep CSRF protection for Native.
- Frame responses contain the requested frame ID; Turbo Streams use stable `dom_id` targets.
- Stimulus reconnects do not duplicate subscriptions; `disconnect` releases resources.
- Native User-Agent changes presentation, not authorization.
- Sign-in errors and password-reset responses do not reveal account existence.
- Password changes and session revocation share the `User#reset_password` transaction.
  Revocation failure rolls back the password; WebSocket disconnect is enqueued after commit.
- Sign-in/reset rate limits and invalid reset tokens redirect to the relevant form with 303.
- Expired sessions redirect to sign-in with 303. Store return URLs only for GET/HEAD;
  sign-in must not replay DELETE or open a mutation route as a page.

## Components

ViewComponent takes explicit keyword arguments and checks fixed variants with `Hash#fetch`.
UI tokens live in `app/assets/tailwind/application.css`. Lookbook is available in development.
The Native Bridge runtime is loaded in `app/javascript/application.js`; add components for concrete features.

[AnyCable](realtime.md) delivers WebSocket updates. Its client already registers
`turbo-cable-stream-source`; do not also load JS `@hotwired/turbo-rails`.
The Ruby `turbo-rails` gem still provides Rails helpers and broadcasting APIs.
Admin screens use invalidation followed by authorized HTML/JSON fetches; they do not poll on a timer.

After form changes, verify success, 422/400 errors, guests, and authenticated users.
After navigation changes, verify Turbo transitions, keyboard access, Android Back/modal behavior,
and Stimulus reconnection. Commands: [README](../README.md), [Android](native.md).
