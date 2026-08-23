///|
test "builder creates a valid SARIF log" {
  let builder = @moonsarif.LogBuilder::new(
    tool_name="MoonLint",
    tool_version="0.4.0",
  )
  builder.add_rule(
    id="MB001",
    name="unsafe-call",
    help_uri="https://example.com/MB001",
  )
  let result_index = builder.add_result(
    rule_id="MB001",
    level="warning",
    message=@moonsarif.message_text("unsafe call"),
    location=@moonsarif.make_location(
      uri="src/main.mbt",
      start_line=12,
      start_column=3,
    ),
  )
  builder.set_partial_fingerprints(result_index, {
    "primaryLocationLineHash": "abc123",
  })
  let log = builder.finish()
  assert_true(@moonsarif.validate(log).is_valid())
  assert_true(@moonsarif.validate_github_compatibility(log).is_valid())
  let reparsed = @moonsarif.parse(@moonsarif.stringify(log))
  assert_eq(log, reparsed)
}

///|
test "builder supports multiple locations and result extensions" {
  let builder = @moonsarif.LogBuilder::new(tool_name="MoonLint")
  let index = builder.add_result(
    rule_id="MB002",
    message=@moonsarif.message_markdown("**related** finding"),
  )
  builder.set_locations(index, [
    @moonsarif.make_location(uri="src/main.mbt", start_line=1),
    @moonsarif.make_location(uri="src/lib.mbt", start_line=2),
  ])
  builder.set_related_locations(index, [
    @moonsarif.make_location(uri="README.md", start_line=3),
  ])
  builder.set_suppressions(index, [
    @moonsarif.make_suppression(kind="inSource", justification="accepted"),
  ])
  builder.set_baseline_state(index, "new")
  let summary = @moonsarif.summarize(builder.finish())
  assert_eq(summary.result_count, 1)
}

///|
test "builder can emit a log without findings" {
  let log = @moonsarif.LogBuilder::new(tool_name="EmptyTool").finish()
  assert_true(@moonsarif.validate(log).is_valid())
  assert_eq(@moonsarif.summarize(log).result_count, 0)
}
