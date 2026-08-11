///|
/// Severity assigned to a validation issue.
pub enum IssueSeverity {
  IssueError
  IssueWarning
} derive(Debug, Eq, ToJson)

///|
/// A machine-readable validation finding.
pub struct ValidationIssue {
  severity : IssueSeverity
  code : String
  path : String
  message : String
} derive(Debug, Eq, ToJson)

///|
/// Complete validation result for one SARIF log.
pub struct ValidationReport {
  issues : Array[ValidationIssue]
} derive(Debug, Eq, ToJson)

///|
/// Whether validation produced no errors.
pub fn ValidationReport::is_valid(self : ValidationReport) -> Bool {
  self.issues.all(fn(issue) { issue.severity != IssueError })
}

///|
/// Count errors in a validation report.
pub fn ValidationReport::error_count(self : ValidationReport) -> Int {
  self.issues.fold(init=0, fn(count, issue) {
    if issue.severity == IssueError {
      count + 1
    } else {
      count
    }
  })
}

///|
/// Count warnings in a validation report.
pub fn ValidationReport::warning_count(self : ValidationReport) -> Int {
  self.issues.fold(init=0, fn(count, issue) {
    if issue.severity == IssueWarning {
      count + 1
    } else {
      count
    }
  })
}

///|
fn add_issue(
  issues : Array[ValidationIssue],
  severity : IssueSeverity,
  code : String,
  path : String,
  message : String,
) -> Unit {
  issues.push({ severity, code, path, message })
}

///|
fn validate_message(
  message : Message,
  path : String,
  issues : Array[ValidationIssue],
) -> Unit {
  let has_text = match message.text {
    Some(text) => !text.trim().is_empty()
    None => false
  }
  let has_markdown = match message.markdown {
    Some(markdown) => !markdown.trim().is_empty()
    None => false
  }
  if !has_text && !has_markdown {
    add_issue(
      issues,
      IssueError,
      "message.empty",
      path,
      "message must contain non-empty text or markdown",
    )
  }
}

///|
fn validate_region(
  region : Region,
  path : String,
  issues : Array[ValidationIssue],
) -> Unit {
  match region.startLine {
    Some(value) if value < 1 =>
      add_issue(
        issues,
        IssueError,
        "region.startLine",
        path + ".startLine",
        "startLine must be greater than zero",
      )
    _ => ()
  }
  match region.startColumn {
    Some(value) if value < 1 =>
      add_issue(
        issues,
        IssueError,
        "region.startColumn",
        path + ".startColumn",
        "startColumn must be greater than zero",
      )
    _ => ()
  }
  match (region.startLine, region.endLine) {
    (Some(start), Some(finish)) if finish < start =>
      add_issue(
        issues,
        IssueError,
        "region.lineOrder",
        path + ".endLine",
        "endLine must not precede startLine",
      )
    _ => ()
  }
}

///|
fn validate_result(
  result : SarifResult,
  path : String,
  known_rules : Map[String, Unit],
  issues : Array[ValidationIssue],
) -> Unit {
  validate_message(result.message, path + ".message", issues)
  match result.level {
    Some("none" | "note" | "warning" | "error") | None => ()
    Some(level) =>
      add_issue(
        issues,
        IssueError,
        "result.level",
        path + ".level",
        "unsupported result level '\{level}'",
      )
  }
  match result.ruleId {
    Some(rule_id) if !known_rules.contains(rule_id) =>
      add_issue(
        issues,
        IssueWarning,
        "result.unknownRule",
        path + ".ruleId",
        "ruleId '\{rule_id}' is not declared by the tool driver",
      )
    _ => ()
  }
  match result.locations {
    Some(locations) =>
      for index, location in locations {
        match location.physicalLocation {
          Some(physical) =>
            match physical.region {
              Some(region) =>
                validate_region(
                  region,
                  path + ".locations[\{index}].physicalLocation.region",
                  issues,
                )
              None => ()
            }
          None => ()
        }
      }
    None => ()
  }
}

///|
/// Perform structural and semantic checks that are useful before uploading a
/// SARIF file to a code-scanning service.
pub fn validate(log : SarifLog) -> ValidationReport {
  let issues : Array[ValidationIssue] = []
  if log.version != "2.1.0" {
    add_issue(
      issues,
      IssueError,
      "log.version",
      "$.version",
      "MoonSARIF currently supports SARIF version 2.1.0",
    )
  }
  if log.runs.is_empty() {
    add_issue(
      issues,
      IssueWarning,
      "log.emptyRuns",
      "$.runs",
      "the log contains no analysis runs",
    )
  }
  for run_index, run in log.runs {
    let run_path = "$.runs[\{run_index}]"
    if run.tool.driver.name.trim().is_empty() {
      add_issue(
        issues,
        IssueError,
        "tool.name",
        run_path + ".tool.driver.name",
        "tool driver name must not be empty",
      )
    }
    let known_rules : Map[String, Unit] = Map([])
    match run.tool.driver.rules {
      Some(rules) =>
        for rule_index, rule in rules {
          if rule.id.trim().is_empty() {
            add_issue(
              issues,
              IssueError,
              "rule.id",
              run_path + ".tool.driver.rules[\{rule_index}].id",
              "rule id must not be empty",
            )
          } else if known_rules.contains(rule.id) {
            add_issue(
              issues,
              IssueError,
              "rule.duplicate",
              run_path + ".tool.driver.rules[\{rule_index}].id",
              "duplicate rule id '\{rule.id}'",
            )
          } else {
            known_rules[rule.id] = ()
          }
        }
      None => ()
    }
    match run.results {
      Some(results) =>
        for result_index, result in results {
          validate_result(
            result,
            run_path + ".results[\{result_index}]",
            known_rules,
            issues,
          )
        }
      None => ()
    }
  }
  { issues, }
}
