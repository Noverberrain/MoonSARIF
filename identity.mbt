///|
/// Return the text that identifies a result for human-facing reports.
fn result_message(result : SarifResult) -> String {
  match result.message.text {
    Some(text) => text
    None =>
      match result.message.markdown {
        Some(markdown) => markdown
        None => ""
      }
  }
}

///|
/// Return a normalized key for the first physical location of a result.
fn result_location_key(result : SarifResult) -> String {
  match result.locations {
    Some(locations) => {
      for location in locations {
        match location.physicalLocation {
          Some(physical) => {
            let path = match physical.artifactLocation {
              Some(artifact) =>
                match artifact.uri {
                  Some(uri) => normalize_path(uri)
                  None => ""
                }
              None => ""
            }
            let line = match physical.region {
              Some(region) =>
                match region.startLine {
                  Some(value) => value.to_string()
                  None => ""
                }
              None => ""
            }
            let column = match physical.region {
              Some(region) =>
                match region.startColumn {
                  Some(value) => value.to_string()
                  None => ""
                }
              None => ""
            }
            return path + ":" + line + ":" + column
          }
          None => ()
        }
      }
      ""
    }
    None => ""
  }
}

///|
/// Build a deterministic identity for a SARIF result.
///
/// The identity intentionally avoids object addresses, array indexes and
/// timestamps. It combines the rule, normalized first location and message;
/// this makes it stable across separate tool runs and useful for de-duplication
/// and baseline comparisons.
pub fn fingerprint(result : SarifResult) -> String {
  let rule = match result.ruleId {
    Some(value) => value
    None => ""
  }
  let location = result_location_key(result)
  let message = result_message(result)
  rule.length().to_string() +
  ":" +
  rule +
  "|" +
  location.length().to_string() +
  ":" +
  location +
  "|" +
  message.length().to_string() +
  ":" +
  message
}

///|
/// Remove duplicate findings from every run while retaining the first result.
pub fn deduplicate(log : SarifLog) -> SarifLog {
  let runs = log.runs.map(fn(run) {
    let seen : Map[String, Unit] = Map([])
    let results = match run.results {
      Some(items) =>
        Some(
          items.filter(fn(result) {
            let key = fingerprint(result)
            if seen.contains(key) {
              false
            } else {
              seen[key] = ()
              true
            }
          }),
        )
      None => None
    }
    { tool: run.tool, results, automationDetails: run.automationDetails }
  })
  { version: log.version, schema: log.schema, runs }
}

///|
/// State of a result when compared with a previous SARIF baseline.
pub enum BaselineState {
  New
  Unchanged
  Absent
} derive(Debug, Eq, ToJson)

///|
/// Aggregate counts produced by a baseline comparison.
pub struct BaselineReport {
  new_results : Int
  unchanged_results : Int
  absent_results : Int
} derive(Debug, Eq, ToJson)

///|
/// Compare unique result identities in `current` with `baseline`.
///
/// Results present only in `current` are new. Results present in both logs are
/// unchanged. Results present only in `baseline` are absent.
pub fn compare_baseline(
  current : SarifLog,
  baseline : SarifLog,
) -> BaselineReport {
  let baseline_keys : Map[String, Unit] = Map([])
  for run in baseline.runs {
    match run.results {
      Some(results) =>
        for result in results {
          baseline_keys[fingerprint(result)] = ()
        }
      None => ()
    }
  }
  let current_keys : Map[String, Unit] = Map([])
  let mut new_results = 0
  let mut unchanged_results = 0
  for run in current.runs {
    match run.results {
      Some(results) =>
        for result in results {
          let key = fingerprint(result)
          if !current_keys.contains(key) {
            current_keys[key] = ()
            let state = if baseline_keys.contains(key) {
              Unchanged
            } else {
              New
            }
            match state {
              New => new_results += 1
              Unchanged => unchanged_results += 1
              Absent => ()
            }
          }
        }
      None => ()
    }
  }
  let mut absent_results = 0
  for key, _ in baseline_keys {
    if !current_keys.contains(key) {
      let state = Absent
      match state {
        Absent => absent_results += 1
        New | Unchanged => ()
      }
    }
  }
  { new_results, unchanged_results, absent_results }
}

///|
/// Add SARIF baselineState values to results in the current log.
///
/// Results found in the baseline are marked `unchanged`; other current
/// results are marked `new`. Baseline-only results are represented by the
/// counts returned from `compare_baseline` and are not added to the current
/// log.
pub fn annotate_baseline(current : SarifLog, baseline : SarifLog) -> SarifLog {
  let baseline_keys : Map[String, Unit] = Map([])
  for run in baseline.runs {
    match run.results {
      Some(results) =>
        for result in results {
          baseline_keys[fingerprint(result)] = ()
        }
      None => ()
    }
  }
  let runs = current.runs.map(fn(run) {
    let results = match run.results {
      Some(items) =>
        Some(
          items.map(fn(result) {
            let state = if baseline_keys.contains(fingerprint(result)) {
              "unchanged"
            } else {
              "new"
            }
            {
              ruleId: result.ruleId,
              ruleIndex: result.ruleIndex,
              level: result.level,
              message: result.message,
              locations: result.locations,
              partialFingerprints: result.partialFingerprints,
              baselineState: Some(state),
            }
          }),
        )
      None => None
    }
    { tool: run.tool, results, automationDetails: run.automationDetails }
  })
  { version: current.version, schema: current.schema, runs }
}
