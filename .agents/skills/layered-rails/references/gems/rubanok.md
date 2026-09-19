# Rails filters and parameters

- Parse input with params.expect and explicit conversions at the HTTP boundary. Select sort columns from a fixed map, never raw SQL interpolation.
- Apply filters to an authorized scope. Keep parameters in the query string for Turbo navigation, reload and Android.
- Keep one simple filter near its query. Extract recurring composition into an explicit query/filter object; do not add a DSL for one screen.
- Reject invalid dates, unknown sort fields, negative sizes and malformed cursors rather than silently defaulting.
- Test adjacent cursor values, page-size boundaries, foreign records and SQL query counts.

Behavior sources: [app/controllers/operations/agents_controller.rb](../../../../../app/controllers/operations/agents_controller.rb), [test/controllers/operations/agents_controller_test.rb](../../../../../test/controllers/operations/agents_controller_test.rb).
