# StarterApp Catalog Workbench

## Paths and Sources of Truth

| Concern | Existing StarterApp source |
| --- | --- |
| Components | `app/components/**/*.rb` and component templates |
| Product usage | `app/views`, components, helpers/presenters, controller render paths |
| Local interaction | `app/javascript/controllers` and existing live-update modules |
| Registered preview classes | `test/components/previews/**/*_preview.rb` |
| Preview layout | `app/views/layouts/component_preview.html.erb` |
| Catalog setup | Gemfile/lockfile, development environment, `config/routes.rb` |
| Tokens and source scanning | `app/assets/tailwind/application.css`, application stylesheets |
| Typography | Shared typography partial/styles and local Martian Mono |
| Navigation/access | Routes, layouts, links/forms, controllers, Action Policy, Native rules |
| Verification | `docs/testing.md`, `docs/development.md`, `bin/ci` |

Lookbook is development-only at `/lookbook`. Do not expose it in production as part of
a catalog task. Follow the installed ViewComponent/Lookbook APIs; inspect gem code/docs
when an annotation/helper is uncertain.

## Evidence and Reports

One source should feed each count shown in a report. Read an existing reliable extractor's
output if present. StarterApp does not currently ship a general Rails component-usage or
flow extractor; use a scoped source survey with `rg` and manual verification, recording
method, revision/date, paths, unresolved dynamic calls, and limitations. Do not label
manual evidence as generated JSON.

If a recurring large audit justifies a Rails-aware extractor, implement and test it for
actual Ruby/ERB patterns before relying on it. Parse source where necessary; regex is a
candidate finder, not proof of transitive reachability. Make output deterministic and
atomic, include provenance, and never fill unknown data with fabricated empty arrays.

For a durable machine-readable report, define the schema and its consumer together.
Keep inputs, derived inventory, usage, routes, and health distinct and linked; do not
maintain independent contradictory component-page graphs. Use an existing profile
document/preview location for human results, and the task response for one-off findings.
Don't add a report framework solely to answer a small question.

## Inventory Semantics

Separate authored domain components, vendored primitives, plain modules/helpers, test/
preview support, experiments, and scaffold. A file's directory is a signal, not sufficient
classification. Count actual production render sites, distinguish literal variant values
from dynamic expressions, and retain unresolved polymorphic/dynamic render calls.

Follow component → parent component/partial → routed template → controller/route. A routed
page can have zero component-style call sites while still being live. Record its served
route separately from the pages where a reusable component appears. Tokens consumed
only by primitives still have consumers; don't drop them from the token map.

Preview coverage has levels: source file exists, framework discovers a preview, preview
renders, and meaningful states are covered. Report the level actually checked. A helper
component imported/rendered incidentally inside a page preview is not automatically covered.

## Real States and Controls

Extract material states from the component API, actual calls, CSS branches, interactions,
loading/empty/error/access behavior, and relevant Native presentation. Prioritize used
variants, then supported but unused ones with honest labels. Don't generate a Cartesian
product of every size/color/role/content combination. Use one case per meaningful visual
or behavioral difference and a shared factory when three or more cases have one shape.

Preview controls should be valid, serializable, and useful: enum selects, booleans, bounded
numbers, text. Hide nonserializable/internal inputs. Read installed Lookbook parameter
syntax before adding controls.
Disable/omit controls for a report that has no meaningful editable input.

## Layout and Visual Contract

- Center and shrink-wrap isolated primitives; don't give every preview full viewport height.
- Give state grids comfortable padding and labels; allow content to determine height.
- Render pages/flows/reports at real widths, including narrow/mobile widths.
- The canvas owns its background and spacing. Embedded canvases must not force `100vh`.
- Use application tokens/typography. Reports use restrained project icons, not emoji.
- Keep one usage/provenance disclosure near the relevant preview, not repeated banners.
- Derived reports can hide provenance by default while keeping it accessible. Experiments
  must visibly state draft/pending/chosen status; that status is not optional provenance.
- Use actual registered preview URLs; unresolved destinations display as source labels,
  not fabricated clickable links.

## Lifecycle and Decisions

Keep production components, experiments, comparisons, and archived decisions distinct.
Use Explore as the experiment group name.
Represent draft/pending/chosen/rejected/archived/deprecated states explicitly in preview
notes or supported metadata.

Retain an experiment when it graduates. Copy/apply the accepted component to production,
write fresh production previews, then annotate the original with date, decision, winner,
destination, and reason. Keep an old production implementation only for live consumers
that need a migration window. No automatic pruning or commits during an audit.

## Scope and Checks

During documentation-only work, record unrelated production bugs with evidence and keep
them outside the change unless the user authorized fixes. A requested component fix can
include its necessary tests without another permission round. Figma writes/publication
still follow the user's actual authorization.

Run appropriate Ruby/ERB syntax/lint, Rails boot/zeitwerk, relevant component/request/
browser tests, and preview rendering. File/static
checks cannot prove that Lookbook discovered a preview or that a dialog works in a WebView.
