///|
let duplicate_log =
  #|{
  #|  "version": "2.1.0",
  #|  "runs": [{
  #|    "tool": { "driver": { "name": "Scanner" } },
  #|    "results": [
  #|      { "ruleId": "R1", "level": "warning", "message": { "text": "same" },
  #|        "locations": [{ "physicalLocation": {
  #|          "artifactLocation": { "uri": "src\\\\a.mbt" },
  #|          "region": { "startLine": 3, "startColumn": 2 }
  #|        }}] },
  #|      { "ruleId": "R1", "level": "warning", "message": { "text": "same" },
  #|        "locations": [{ "physicalLocation": {
  #|          "artifactLocation": { "uri": "src/a.mbt" },
  #|          "region": { "startLine": 3, "startColumn": 2 }
  #|        }}] }
  #|    ]
  #|  }]
  #|}

///|
test "fingerprint is stable across path separators" {
  let log = @moonsarif.parse(duplicate_log)
  guard log.runs[0].results is Some(results) else { fail("missing results") }
  assert_eq(
    @moonsarif.fingerprint(results[0]),
    @moonsarif.fingerprint(results[1]),
  )
}

///|
test "deduplicate keeps the first result" {
  let log = @moonsarif.parse(duplicate_log)
  let unique = @moonsarif.deduplicate(log)
  assert_eq(@moonsarif.summarize(unique).result_count, 1)
}

///|
test "baseline counts new unchanged and absent results" {
  let baseline = @moonsarif.parse(
    (
      #|{
      #|  "version": "2.1.0",
      #|  "runs": [{
      #|    "tool": { "driver": { "name": "Scanner" } },
      #|    "results": [
      #|      { "ruleId": "OLD", "message": { "text": "old" } },
      #|      { "ruleId": "KEEP", "message": { "text": "keep" } }
      #|    ]
      #|  }]
      #|}
    ),
  )
  let current = @moonsarif.parse(
    (
      #|{
      #|  "version": "2.1.0",
      #|  "runs": [{
      #|    "tool": { "driver": { "name": "Scanner" } },
      #|    "results": [
      #|      { "ruleId": "KEEP", "message": { "text": "keep" } },
      #|      { "ruleId": "NEW", "message": { "text": "new" } }
      #|    ]
      #|  }]
      #|}
    ),
  )
  let report = @moonsarif.compare_baseline(current, baseline)
  assert_eq(report.new_results, 1)
  assert_eq(report.unchanged_results, 1)
  assert_eq(report.absent_results, 1)
}
