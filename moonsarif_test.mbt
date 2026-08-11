///|
let valid_log =
  #|{
  #|  "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
  #|  "version": "2.1.0",
  #|  "runs": [
  #|    {
  #|      "tool": {
  #|        "driver": {
  #|          "name": "MoonLint",
  #|          "version": "1.0.0",
  #|          "rules": [
  #|            {
  #|              "id": "MB001",
  #|              "shortDescription": { "text": "Avoid unsafe calls" }
  #|            },
  #|            {
  #|              "id": "MB002",
  #|              "shortDescription": { "text": "Remove dead code" }
  #|            }
  #|          ]
  #|        }
  #|      },
  #|      "results": [
  #|        {
  #|          "ruleId": "MB001",
  #|          "level": "error",
  #|          "message": { "text": "unsafe call may panic" },
  #|          "locations": [
  #|            {
  #|              "physicalLocation": {
  #|                "artifactLocation": { "uri": "src\\main.mbt" },
  #|                "region": { "startLine": 12, "startColumn": 3 }
  #|              }
  #|            }
  #|          ],
  #|          "partialFingerprints": { "primaryLocationLineHash": "abc123" }
  #|        },
  #|        {
  #|          "ruleId": "MB002",
  #|          "level": "warning",
  #|          "message": { "markdown": "**unused** declaration" },
  #|          "locations": [
  #|            {
  #|              "physicalLocation": {
  #|                "artifactLocation": { "uri": "src/lib.mbt" },
  #|                "region": { "startLine": 8 }
  #|              }
  #|            }
  #|          ]
  #|        }
  #|      ]
  #|    }
  #|  ]
  #|}

///|
test "parse and serialize SARIF 2.1.0" {
  let log = @moonsarif.parse(valid_log)
  let encoded = @moonsarif.stringify(log, pretty=true)
  assert_true(encoded.contains("\"$schema\""))
  assert_true(encoded.contains("\"version\": \"2.1.0\""))
  let reparsed = @moonsarif.parse(encoded)
  assert_eq(log, reparsed)
}

///|
test "summarize results by severity and rule" {
  let summary = @moonsarif.summarize(@moonsarif.parse(valid_log))
  debug_inspect(
    summary,
    content=(
      #|{
      #|  run_count: 1,
      #|  result_count: 2,
      #|  error_count: 1,
      #|  warning_count: 1,
      #|  note_count: 0,
      #|  none_count: 0,
      #|  unknown_level_count: 0,
      #|  unique_rule_count: 2,
      #|}
    ),
  )
}

///|
test "validate a healthy log" {
  let report = @moonsarif.validate(@moonsarif.parse(valid_log))
  assert_true(report.is_valid())
  assert_eq(report.error_count(), 0)
  assert_eq(report.warning_count(), 0)
}

///|
test "validation reports semantic problems" {
  let input =
    #|{
    #|  "version": "2.0.0",
    #|  "runs": [{
    #|    "tool": {
    #|      "driver": {
    #|        "name": "",
    #|        "rules": [{ "id": "DUP" }, { "id": "DUP" }]
    #|      }
    #|    },
    #|    "results": [{
    #|      "ruleId": "UNKNOWN",
    #|      "level": "critical",
    #|      "message": {},
    #|      "locations": [{
    #|        "physicalLocation": {
    #|          "region": { "startLine": 0, "endLine": -1 }
    #|        }
    #|      }]
    #|    }]
    #|  }]
    #|}
  let report = @moonsarif.validate(@moonsarif.parse(input))
  assert_false(report.is_valid())
  assert_eq(report.error_count(), 7)
  assert_eq(report.warning_count(), 1)
}

///|
test "filter results by level, rule and normalized path" {
  let log = @moonsarif.parse(valid_log)
  let errors = @moonsarif.filter_results(log, level="error")
  assert_eq(@moonsarif.summarize(errors).result_count, 1)
  let matching_path = @moonsarif.filter_results(
    log,
    rule_id="MB001",
    path_contains="src/main.mbt",
  )
  assert_eq(@moonsarif.summarize(matching_path).result_count, 1)
  let missing = @moonsarif.filter_results(log, path_contains="tests/")
  assert_eq(@moonsarif.summarize(missing).result_count, 0)
}

///|
test "merge compatible logs" {
  let first = @moonsarif.parse(valid_log)
  let second = @moonsarif.parse(valid_log)
  guard @moonsarif.merge([first, second]) is Some(merged) else {
    fail("expected compatible logs to merge")
  }
  assert_eq(@moonsarif.summarize(merged).run_count, 2)
  assert_eq(@moonsarif.summarize(merged).result_count, 4)
}

///|
test "reject malformed and incomplete JSON" {
  try @moonsarif.parse("{") catch {
    _ => ()
  } noraise {
    _ => fail("expected malformed JSON to fail")
  }
  try @moonsarif.parse("{\"version\":\"2.1.0\"}") catch {
    _ => ()
  } noraise {
    _ => fail("expected missing runs to fail")
  }
}

///|
test "normalize cross-platform artifact paths" {
  assert_eq(
    @moonsarif.normalize_path("src\\generated\\..\\main.mbt"),
    "src/main.mbt",
  )
  assert_eq(@moonsarif.normalize_path("/a//b/./c"), "/a/b/c")
}
