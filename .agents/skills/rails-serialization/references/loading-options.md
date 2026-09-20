# Loading Options at the Rails Boundary

| Loading requirement | Implementation | Contract |
| --- | --- | --- |
| Regular value | Query once and render current HTML/JSON | Required fields present and authorized |
| Lazy evaluation | Query only in the selected request branch | No hidden work while serializing unrelated fields |
| Optional | Separate explicit endpoint/frame | Direct requests authorize independently |
| Deferred | Eager source frame or persisted job result | Placeholder, loading, error, and ready states |
| Deferred group | One region/endpoint for related data | Related results arrive coherently |
| Once | Normal rendering, or a measured versioned server cache | Access/tenant/locale and invalidation considered |
| Once with expiry | Explicit cache freshness/expiry policy | Expiry doesn't replace authorization |
| Always | Essential layout/response fields | Minimal shared contract, not a global data dump |
| Merge/append | Stream append/update using stable IDs | Duplicate and ordering behavior explicit |
| Deep merge | Explicit domain update or fragment replacement | No generic recursive merge of untrusted input |
| Scroll | Bounded query, stable cursor, progressive list/frame | Reset on filter change; end/error/manual load |
| Reset | New query/list for changed filter | Stale in-flight responses don't reinsert old rows |

## Combining Options

For grouped deferred data that later grows, separate the concerns: one authorized frame
loads the initial group; pagination queries produce stable-ID rows; a stream appends them;
filter changes replace the list and reset its cursor. Keep these responsibilities explicit.

For rarely changing reference data, first render it normally. If measurement warrants
caching, choose a key that includes relevant version/access/locale dimensions and a
deliberate expiry. Cache the correct representation at one layer. Clearing Turbo snapshots
does not expire Rails cache entries or revoke an exposed private payload.

Long AI generation belongs in a job after commit, with persisted state and private
invalidation/delivery through the existing AnyCable system. Serialization only describes
the resulting authorized response; it must not start a model call while rendering.
