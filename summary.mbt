///|
/// Compact metrics for a SARIF log.
pub struct SarifSummary {
  run_count : Int
  result_count : Int
  error_count : Int
  warning_count : Int
  note_count : Int
  none_count : Int
  unknown_level_count : Int
  unique_rule_count : Int
} derive(Debug, Eq, ToJson)

///|
/// Build an aggregate summary across every run.
pub fn summarize(log : SarifLog) -> SarifSummary {
  let mut result_count = 0
  let mut error_count = 0
  let mut warning_count = 0
  let mut note_count = 0
  let mut none_count = 0
  let mut unknown_level_count = 0
  let rules : Map[String, Unit] = Map([])
  for run in log.runs {
    match run.results {
      Some(results) =>
        for result in results {
          result_count += 1
          match result.level {
            Some("error") => error_count += 1
            Some("warning") => warning_count += 1
            Some("note") => note_count += 1
            Some("none") | None => none_count += 1
            Some(_) => unknown_level_count += 1
          }
          match result.ruleId {
            Some(rule_id) => rules[rule_id] = ()
            None => ()
          }
        }
      None => ()
    }
  }
  {
    run_count: log.runs.length(),
    result_count,
    error_count,
    warning_count,
    note_count,
    none_count,
    unknown_level_count,
    unique_rule_count: rules.length(),
  }
}

///|
fn result_has_path(result : SarifResult, needle : StringView) -> Bool {
  match result.locations {
    Some(locations) =>
      locations.any(fn(location) {
        match location.physicalLocation {
          Some(physical) =>
            match physical.artifactLocation {
              Some(artifact) =>
                match artifact.uri {
                  Some(uri) => normalize_path(uri).contains(needle)
                  None => false
                }
              None => false
            }
          None => false
        }
      })
    None => false
  }
}

///|
/// Filter results while preserving run and tool metadata.
pub fn filter_results(
  log : SarifLog,
  level? : String,
  rule_id? : String,
  path_contains? : String,
) -> SarifLog {
  let runs = log.runs.map(fn(run) {
    let results = match run.results {
      Some(items) =>
        Some(
          items.filter(fn(result) {
            let level_matches = match level {
              Some(expected) => result.level == Some(expected)
              None => true
            }
            let rule_matches = match rule_id {
              Some(expected) => result.ruleId == Some(expected)
              None => true
            }
            let path_matches = match path_contains {
              Some(expected) =>
                result_has_path(result, normalize_path(expected))
              None => true
            }
            level_matches && rule_matches && path_matches
          }),
        )
      None => None
    }
    { tool: run.tool, results, automationDetails: run.automationDetails }
  })
  { version: log.version, schema: log.schema, runs }
}

///|
/// Merge logs by concatenating runs. All inputs must use the same version.
pub fn merge(logs : ArrayView[SarifLog]) -> SarifLog? {
  guard logs is [first, .. rest] else { return None }
  let runs = first.runs.copy()
  for log in rest {
    if log.version != first.version {
      return None
    }
    for run in log.runs {
      runs.push(run)
    }
  }
  Some({ version: first.version, schema: first.schema, runs })
}
