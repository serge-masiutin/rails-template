---
name: rails-serialization
description: Serialize explicit JSON boundaries in StarterApp Rails without leaking model data; keep entity, page, shared, loading, and consumer type contracts separate. Use for APIs, Native messages, and the existing trace viewer.
---

# Rails Serialization

Keep reusable entity shapes, page-specific responses, shared data, loading policy,
and consumer types separate. StarterApp renders ordinary pages as HTML. Use explicit
Ruby contracts at JSON boundaries.

## Setup: Establish Whether Serialization Is Needed

For an ordinary Rails page, pass authorized records/view inputs to ERB/ViewComponent.
Do not create a serializer for every template. For a JSON consumer, inspect its schema,
authentication, access scope, content limits, and existing serializer before adding one.
`AgentTraceDocument` is the trace allowlist; preserve it instead of inventing a second
trace serializer that exposes raw model/provider payloads.

## Entity Shape

Use a named small serializer/value object when the shape is reused. List fields rather
than calling unrestricted `as_json` on a model. Pass context explicitly where needed;
serialization should not query, mutate, send notifications, or consult hidden global state.

```ruby
class ProjectSummary
  def initialize(project)
    @project = project
  end

  def as_json(*)
    {
      id: @project.id,
      name: @project.name,
      updated_at: @project.updated_at.iso8601
    }
  end
end
```

This is an illustrative feature object, not an existing StarterApp class. Confirm ID
representation and timestamp precision with the consumer contract. Preload associations
in the query layer if the shape needs them; test collection growth for N+1.

## Page-Specific Response

Compose only the entities and metadata a real JSON consumer needs. Keep pagination,
filters, totals, and domain records distinct. Authorize and scope before serializing.
Don't let a serializer choose the actor's accessible collection implicitly.

```ruby
def index
  authorize! Project
  projects = authorized_scope(Project.all).order(:id).limit(50)
  render json: { projects: projects.map { |project| ProjectSummary.new(project).as_json } }
end
```

The example demonstrates a bounded shape, not a complete pagination API. A production
collection contract must define navigation/cursors and limits appropriate to the feature.
For HTML pages, use the standard ERB response instead of this JSON path.

## Shared Data

Shared layout information stays in Rails helpers/context. If a JS consumer truly needs
shared configuration, expose a minimal explicit allowlist with required/optional fields.
Do not serialize Current, the whole user, session tokens, or arbitrary settings.
Translation dictionaries are produced from Rails keys for the actual feature; there
is no second handwritten JS copy of the application's English strings.

## Explicit Rendering and Naming

There is no implicit `{Controller}{Action}Resource` lookup or automatic instance-variable
serialization in this project. Use explicit `render json:` or HTML rendering with
named inputs. Name the serializer by domain/consumer when that makes its purpose clear.
Keep page-only fields out of a reusable entity shape; use composition rather than
inventing a universal `ApplicationResource` abstraction with hidden behavior.

## Types and Schema

Read `hotwire-contracts`. Define nullability, omitted fields, IDs, enums, date/time units,
array order, and schema/version. Test exactly the security-sensitive allowlist. A TypeScript
interface or Kotlin data class cannot validate arbitrary network JSON by itself.
No Alba/Typelizer generation is active; if later introduced, record the actual generator,
inputs, output directory, commands, and consumers and keep generation reproducible.

## Loading Options

Read [loading-options.md](references/loading-options.md) for the complete mapping of
regular, optional, deferred/grouped, once/expiry, merge/deep-merge, always, and scroll
options. Loading belongs to the request/job/UI boundary, not a side effect of serializing
an attribute. Don't invent `defer:` or `once:` keyword APIs on plain Ruby serializers.

## Troubleshooting

| Symptom | Cause to investigate | Resolution |
| --- | --- | --- |
| Unexpected/private fields | Unrestricted model JSON or merged SDK payload | Restore explicit allowlist and negative access tests |
| Collection is slow | Serializer queries per item | Preload at query boundary, verify N+1 |
| Consumer missing field | Producer/consumer schema drift | Update both and test version compatibility |
| Null silently becomes empty | Undocumented default/optional chaining | Define optionality and reject malformed required input |
| “Resource not found” expectation | Copied Alba naming convention | Use actual explicit Rails render path |
| Types never generated | Generator not installed/configured | Use actual contract; don't claim a nonexistent task |
| Stale or unauthorized cached JSON | Missing access/version scope | Recheck authorization and correct cache boundary |

## Gate

Verify exact allowlist where sensitive, access for guest/owner/foreign/admin as applicable,
malformed external input, collection size/query behavior, consumer parsing/compilation,
and backward compatibility for installed Native clients. Never include real secrets,
user documents, prompt bodies, or raw traces in fixtures.
