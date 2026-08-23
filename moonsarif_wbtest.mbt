///|
test "result path matching normalizes separators" {
  let result : SarifResult = {
    ruleId: Some("PATH"),
    ruleIndex: None,
    level: Some("warning"),
    message: { text: Some("path test"), markdown: None },
    locations: Some([
      {
        physicalLocation: Some({
          artifactLocation: Some({
            uri: Some("src\\nested\\file.mbt"),
            uriBaseId: None,
            index: None,
          }),
          region: None,
        }),
        message: None,
      },
    ]),
    relatedLocations: None,
    partialFingerprints: None,
    fingerprints: None,
    suppressions: None,
    fixes: None,
    properties: None,
    baselineState: None,
  }
  assert_true(result_has_path(result, "nested/file"))
  assert_false(result_has_path(result, "tests/"))
}
