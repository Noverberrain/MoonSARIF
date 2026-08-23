///|
/// Validate the subset of SARIF conventions expected by GitHub Code Scanning.
///
/// This complements `validate` with checks that are useful immediately before
/// uploading a SARIF artifact. It intentionally remains conservative: missing
/// locations are warnings because some analyzers emit project-level findings.
pub fn validate_github_compatibility(log : SarifLog) -> ValidationReport {
  let report = validate(log)
  let issues = report.issues.copy()
  if log.version != "2.1.0" {
    add_issue(
      issues,
      IssueError,
      "github.version",
      "$.version",
      "GitHub Code Scanning expects SARIF version 2.1.0",
    )
  }
  for run_index, run in log.runs {
    let run_path = "$.runs[\{run_index}]"
    if run.tool.driver.name.trim().is_empty() {
      add_issue(
        issues,
        IssueError,
        "github.tool.name",
        run_path + ".tool.driver.name",
        "tool driver name is required by GitHub Code Scanning",
      )
    }
    match run.results {
      Some(results) =>
        for result_index, result in results {
          let result_path = run_path + ".results[\{result_index}]"
          match result.ruleId {
            Some(rule_id) if !rule_id.trim().is_empty() => ()
            _ =>
              add_issue(
                issues,
                IssueError,
                "github.result.ruleId",
                result_path + ".ruleId",
                "result ruleId is required by GitHub Code Scanning",
              )
          }
          match result.locations {
            Some(locations) if !locations.is_empty() =>
              validate_github_locations(locations, result_path, issues)
            Some(_) | None =>
              add_issue(
                issues,
                IssueWarning,
                "github.result.location",
                result_path + ".locations",
                "result has no location; GitHub may display it as a project-level finding",
              )
          }
          match result.baselineState {
            Some("new" | "unchanged" | "absent") | None => ()
            Some(_) =>
              add_issue(
                issues,
                IssueError,
                "github.result.baselineState",
                result_path + ".baselineState",
                "baselineState must be new, unchanged, or absent",
              )
          }
        }
      None => ()
    }
  }
  { issues, }
}

///|
fn validate_github_locations(
  locations : Array[Location],
  path : String,
  issues : Array[ValidationIssue],
) -> Unit {
  for index, location in locations {
    match location.physicalLocation {
      Some(physical) =>
        match physical.artifactLocation {
          Some(artifact) =>
            match artifact.uri {
              Some(uri) if !uri.trim().is_empty() =>
                if uri.contains("\\") {
                  add_issue(
                    issues,
                    IssueWarning,
                    "github.location.path",
                    path +
                    ".locations[\{index}].physicalLocation.artifactLocation.uri",
                    "artifact URI uses backslashes; normalize it before upload",
                  )
                }
              _ =>
                add_issue(
                  issues,
                  IssueWarning,
                  "github.location.path",
                  path +
                  ".locations[\{index}].physicalLocation.artifactLocation.uri",
                  "physical location has no artifact URI",
                )
            }
          None =>
            add_issue(
              issues,
              IssueWarning,
              "github.location.path",
              path + ".locations[\{index}].physicalLocation",
              "physical location has no artifact location",
            )
        }
      None =>
        add_issue(
          issues,
          IssueWarning,
          "github.location.physical",
          path + ".locations[\{index}]",
          "location has no physicalLocation",
        )
    }
  }
}
