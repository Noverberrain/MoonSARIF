///|
test "github compatibility accepts sample findings" {
  let report = @moonsarif.validate_github_compatibility(
    @moonsarif.parse(valid_log),
  )
  assert_true(report.is_valid())
  assert_true(report.warning_count() >= 1)
}

///|
test "github compatibility rejects missing rule and invalid baseline" {
  let log = @moonsarif.parse(
    (
      #|{
      #|  "version": "2.1.0",
      #|  "runs": [{
      #|    "tool": { "driver": { "name": "Scanner" } },
      #|    "results": [{
      #|      "level": "warning",
      #|      "message": { "text": "project finding" },
      #|      "baselineState": "invalid"
      #|    }]
      #|  }]
      #|}
    ),
  )
  let report = @moonsarif.validate_github_compatibility(log)
  assert_false(report.is_valid())
  assert_eq(report.error_count(), 2)
  assert_true(report.warning_count() >= 1)
}
