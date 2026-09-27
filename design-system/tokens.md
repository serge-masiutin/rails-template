# Rails Template tokens

[ui_tokens.css](../app/assets/stylesheets/ui_tokens.css) owns light-theme values.
All tokens below are colors. [Tailwind](../app/assets/tailwind/application.css)
exposes base roles through `@theme inline`; admin-only roles are consumed directly
by [admin_navigation.css](../app/assets/stylesheets/admin_navigation.css).

| Role | Token | Use |
| --- | --- | --- |
| Page canvas | `--ui-canvas` | Application background |
| Surface | `--ui-surface` | Panels, fields, navigation; text on accent actions |
| Primary text | `--ui-ink` | Content and headings |
| Secondary text | `--ui-muted` | Product hints and supporting copy |
| Accent | `--ui-accent` | Main action, links, visible focus |
| Boundary | `--ui-line` | Neutral borders and dividers |
| Success | `--ui-success` | Completed-action feedback |
| Danger | `--ui-danger` | Validation errors and destructive actions |
| Admin secondary text | `--ui-navigation-muted` | Navigation and dashboard captions |
| Navigation hover | `--ui-navigation-hover` | Hovered link background |
| Current navigation | `--ui-navigation-current`, `--ui-navigation-current-ink` | Selected link background and text |
| Live connection | `--ui-status-live` | Connected live-update indicator |
| Paused connection | `--ui-status-paused` | Paused live-update indicator |
| Problem surface | `--ui-danger-line`, `--ui-danger-surface` | Error metric border and background |

Use roles, not matching values. Admin muted text intentionally retains its existing
value, separate from product muted text. Connection status is not business-operation
success. State colors supplement a textual label. Existing resolved colors are
preserved by the token extraction; no dark theme is provided.

[typography.css](../app/assets/stylesheets/typography.css) defines `--font-ui` and
local Martian Mono. Keep existing Tailwind spacing/radius utilities and shell CSS;
there is no additional custom global scale. Components own internal dimensions;
consumers own the spacing and order between regions.
