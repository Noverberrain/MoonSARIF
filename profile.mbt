///|
/// Validation rules to apply to a SARIF log.
pub enum ValidationProfile {
  Generic
  Github
  Strict
} derive(Debug, Eq, ToJson)

///|
/// Return the generic validation profile.
pub fn generic_validation_profile() -> ValidationProfile {
  Generic
}

///|
/// Return the GitHub validation profile.
pub fn github_validation_profile() -> ValidationProfile {
  Github
}

///|
/// Return the strict validation profile.
pub fn strict_validation_profile() -> ValidationProfile {
  Strict
}

///|
/// Parse the profile name used by the command-line interface.
pub fn parse_validation_profile(value : String) -> ValidationProfile? {
  match value {
    "generic" => Some(Generic)
    "github" => Some(Github)
    "strict" => Some(Strict)
    _ => None
  }
}

///|
/// Validate a SARIF log using a named engineering profile.
pub fn validate_with_profile(
  log : SarifLog,
  profile : ValidationProfile,
) -> ValidationReport {
  match profile {
    Generic => validate(log)
    Github => validate_github_compatibility(log)
    Strict => validate_strict(log)
  }
}

///|
fn validate_strict(log : SarifLog) -> ValidationReport {
  let base = validate_github_compatibility(log)
  let issues = base.issues.copy()
  let fingerprints : Map[String, Unit] = Map([])
  for run_index, run in log.runs {
    let run_path = "$.runs[\{run_index}]"
    let known_rules : Map[String, Unit] = Map([])
    match run.tool.driver.rules {
      Some(rules) =>
        for rule in rules {
          known_rules[rule.id] = ()
        }
      None => ()
    }
    match run.results {
      Some(results) =>
        for result_index, result in results {
          let result_path = run_path + ".results[\{result_index}]"
          match result.ruleId {
            Some(rule_id) if known_rules.contains(rule_id) => ()
            Some(rule_id) =>
              add_issue(
                issues,
                IssueError,
                "strict.result.undeclaredRule",
                result_path + ".ruleId",
                "ruleId '\{rule_id}' must be declared by the tool driver",
              )
            None =>
              add_issue(
                issues,
                IssueError,
                "strict.result.ruleId",
                result_path + ".ruleId",
                "strict profile requires result ruleId",
              )
          }
          match result.locations {
            Some(locations) if !locations.is_empty() =>
              for _, location in locations {
                match location.physicalLocation {
                  Some(physical) =>
                    match physical.artifactLocation {
                      Some(artifact) =>
                        match artifact.uri {
                          Some(uri) if is_relative_uri(uri) => ()
                          Some(_) | None =>
                            add_issue(
                              issues,
                              IssueError,
                              "strict.location.uri",
                              result_path + ".locations",
                              "strict profile requires a relative artifact URI",
                            )
                        }
                      None =>
                        add_issue(
                          issues,
                          IssueError,
                          "strict.location.uri",
                          result_path + ".locations",
                          "strict profile requires an artifact location",
                        )
                    }
                  None =>
                    add_issue(
                      issues,
                      IssueError,
                      "strict.location.physical",
                      result_path + ".locations",
                      "strict profile requires a physical location",
                    )
                }
              }
            Some(_) | None =>
              add_issue(
                issues,
                IssueError,
                "strict.result.location",
                result_path + ".locations",
                "strict profile requires at least one location",
              )
          }
          let key = fingerprint(result)
          if fingerprints.contains(key) {
            add_issue(
              issues,
              IssueError,
              "strict.result.duplicateFingerprint",
              result_path,
              "strict profile forbids duplicate result fingerprints",
            )
          } else {
            fingerprints[key] = ()
          }
        }
      None => ()
    }
  }
  { issues, }
}

///|
fn is_relative_uri(uri : String) -> Bool {
  !uri.trim().is_empty() &&
  !uri.has_prefix("/") &&
  !uri.has_prefix("\\") &&
  !uri.contains("://") &&
  !(uri.length() >= 2 && uri[1] == ':')
}
