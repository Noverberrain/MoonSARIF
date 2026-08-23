///|
test "roundtrip common SARIF result extensions" {
  let input =
    #|{
    #|  "version": "2.1.0",
    #|  "runs": [{
    #|    "tool": { "driver": { "name": "Scanner" } },
    #|    "results": [{
    #|      "ruleId": "R1",
    #|      "message": { "text": "finding" },
    #|      "relatedLocations": [{
    #|        "physicalLocation": {
    #|          "artifactLocation": { "uri": "src/helper.mbt" },
    #|          "region": { "startLine": 4 }
    #|        }
    #|      }],
    #|      "fingerprints": { "primary": "abc" },
    #|      "suppressions": [{
    #|        "kind": "inSource",
    #|        "justification": "accepted for compatibility",
    #|        "guid": "suppression-1"
    #|      }],
    #|      "fixes": [{
    #|        "description": { "text": "Replace with a safer API" },
    #|        "artifactChanges": [{
    #|          "artifactLocation": { "uri": "src/main.mbt" },
    #|          "replacements": [{
    #|            "deletedRegion": { "startLine": 8, "startColumn": 1, "endLine": 8, "endColumn": 12 },
    #|            "insertedContent": { "text": "safe_call()" }
    #|          }]
    #|        }]
    #|      }],
    #|      "properties": { "owner": "security" }
    #|    }]
    #|  }]
    #|}
  let log = @moonsarif.parse(input)
  let encoded = @moonsarif.stringify(log)
  assert_true(encoded.contains("relatedLocations"))
  assert_true(encoded.contains("fingerprints"))
  assert_true(encoded.contains("suppressions"))
  assert_true(encoded.contains("fixes"))
  assert_true(encoded.contains("properties"))
  assert_eq(log, @moonsarif.parse(encoded))
}
