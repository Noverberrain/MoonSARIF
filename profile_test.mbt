///|
test "validation profiles preserve generic and github behavior" {
  let log = @moonsarif.parse(
    (
      #|{
      #|  "version": "2.1.0",
      #|  "runs": [{
      #|    "tool": { "driver": { "name": "ProfileTool", "rules": [{ "id": "P001" }] } },
      #|    "results": [{
      #|      "ruleId": "P001",
      #|      "message": { "text": "profile finding" },
      #|      "locations": [{ "physicalLocation": { "artifactLocation": { "uri": "src/main.mbt" }, "region": { "startLine": 1 } } }]
      #|    }]
      #|  }]
      #|}
    ),
  )
  assert_true(
    @moonsarif.validate_with_profile(
      log,
      @moonsarif.generic_validation_profile(),
    ).is_valid(),
  )
  assert_true(
    @moonsarif.validate_with_profile(
      log,
      @moonsarif.github_validation_profile(),
    ).is_valid(),
  )
  assert_true(
    @moonsarif.validate_with_profile(
      log,
      @moonsarif.strict_validation_profile(),
    ).is_valid(),
  )
}

///|
test "strict profile rejects undeclared rules and project locations" {
  let log = @moonsarif.parse(
    (
      #|{
      #|  "version": "2.1.0",
      #|  "runs": [{
      #|    "tool": { "driver": { "name": "ProfileTool" } },
      #|    "results": [{ "ruleId": "UNKNOWN", "message": { "text": "finding" } }]
      #|  }]
      #|}
    ),
  )
  let report = @moonsarif.validate_with_profile(
    log,
    @moonsarif.strict_validation_profile(),
  )
  assert_false(report.is_valid())
  assert_true(report.error_count() >= 2)
}
