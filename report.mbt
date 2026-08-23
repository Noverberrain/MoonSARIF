///|
/// Return the result message used by human-facing reports.
fn report_message(result : SarifResult) -> String {
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
fn report_level(result : SarifResult) -> String {
  match result.level {
    Some(level) => level
    None => "none"
  }
}

///|
fn report_baseline_state(result : SarifResult) -> String {
  match result.baselineState {
    Some(state) => state
    None => "-"
  }
}

///|
fn format_location(location : Location) -> String? {
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
      if path.is_empty() {
        None
      } else {
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
        let line_suffix = match line.is_empty() {
          true => ""
          false => ":" + line
        }
        let column_suffix = match column.is_empty() {
          true => ""
          false => ":" + column
        }
        Some(path + line_suffix + column_suffix)
      }
    }
    None => None
  }
}

///|
fn report_location(result : SarifResult) -> String {
  match result.locations {
    Some(locations) => {
      for location in locations {
        match format_location(location) {
          Some(value) => return value
          None => ()
        }
      }
      "-"
    }
    None => "-"
  }
}

///|
fn markdown_cell(value : String) -> String {
  value.replace(old="|", new="\\|").replace(old="\n", new="<br>")
}

///|
fn html_escape(value : String) -> String {
  value
  .replace(old="&", new="&amp;")
  .replace(old="<", new="&lt;")
  .replace(old=">", new="&gt;")
  .replace(old="\"", new="&quot;")
  .replace(old="'", new="&#39;")
  .replace(old="\n", new="<br>")
}

///|
/// Render a compact Markdown report for a SARIF log.
pub fn render_markdown(log : SarifLog) -> String {
  let summary = summarize(log)
  let output = "# MoonSARIF Report\n\n" +
    "## Summary\n\n" +
    "| Metric | Value |\n| --- | ---: |\n" +
    "| Runs | " +
    summary.run_count.to_string() +
    " |\n" +
    "| Results | " +
    summary.result_count.to_string() +
    " |\n" +
    "| Errors | " +
    summary.error_count.to_string() +
    " |\n" +
    "| Warnings | " +
    summary.warning_count.to_string() +
    " |\n" +
    "| Notes | " +
    summary.note_count.to_string() +
    " |\n" +
    "| None | " +
    summary.none_count.to_string() +
    " |\n" +
    "| Rules | " +
    summary.unique_rule_count.to_string() +
    " |\n\n" +
    "## Findings\n\n" +
    "| # | Level | Rule | Location | Message | Baseline |\n" +
    "| ---: | --- | --- | --- | --- | --- |\n"
  let mut body = ""
  let mut index = 1
  for run in log.runs {
    match run.results {
      Some(results) =>
        for result in results {
          let rule = match result.ruleId {
            Some(value) => value
            None => "-"
          }
          body += "| " +
            index.to_string() +
            " | " +
            markdown_cell(report_level(result)) +
            " | " +
            markdown_cell(rule) +
            " | " +
            markdown_cell(report_location(result)) +
            " | " +
            markdown_cell(report_message(result)) +
            " | " +
            markdown_cell(report_baseline_state(result)) +
            " |\n"
          index += 1
        }
      None => ()
    }
  }
  output + body
}

///|
/// Render a self-contained HTML report for a SARIF log.
pub fn render_html(log : SarifLog) -> String {
  let summary = summarize(log)
  let mut rows = ""
  let mut index = 1
  for run in log.runs {
    match run.results {
      Some(results) =>
        for result in results {
          let rule = match result.ruleId {
            Some(value) => value
            None => "-"
          }
          let level = report_level(result)
          rows += "<tr><td>" +
            index.to_string() +
            "</td><td><span class=\"level " +
            html_escape(level) +
            "\">" +
            html_escape(level) +
            "</span></td><td>" +
            html_escape(rule) +
            "</td><td>" +
            html_escape(report_location(result)) +
            "</td><td>" +
            html_escape(report_message(result)) +
            "</td><td>" +
            html_escape(report_baseline_state(result)) +
            "</td></tr>\n"
          index += 1
        }
      None => ()
    }
  }
  "<!doctype html>\n<html lang=\"en\"><head><meta charset=\"utf-8\">" +
  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" +
  "<title>MoonSARIF Report</title><style>" +
  "body{font-family:system-ui,-apple-system,Segoe UI,sans-serif;margin:2rem;color:#172033;background:#f7f9fc}" +
  ".card{background:white;border:1px solid #dbe3ef;border-radius:12px;padding:1.25rem;margin-bottom:1rem;box-shadow:0 2px 8px #17203312}" +
  "h1{margin-top:0;color:#155eef}table{border-collapse:collapse;width:100%;font-size:.92rem}" +
  "th,td{border-bottom:1px solid #e5eaf2;padding:.65rem;text-align:left;vertical-align:top}" +
  "th{background:#f1f5fb}.metrics{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:.75rem}" +
  ".metric{background:#f1f5fb;border-radius:8px;padding:.75rem}.metric b{display:block;font-size:1.4rem}" +
  ".level{font-weight:650}.level.error{color:#b42318}.level.warning{color:#b54708}.level.note{color:#175cd3}.level.none{color:#667085}" +
  "</style></head><body><div class=\"card\"><h1>MoonSARIF Report</h1>" +
  "<div class=\"metrics\"><div class=\"metric\"><b>" +
  summary.run_count.to_string() +
  "</b>Runs</div><div class=\"metric\"><b>" +
  summary.result_count.to_string() +
  "</b>Results</div><div class=\"metric\"><b>" +
  summary.error_count.to_string() +
  "</b>Errors</div><div class=\"metric\"><b>" +
  summary.warning_count.to_string() +
  "</b>Warnings</div><div class=\"metric\"><b>" +
  summary.note_count.to_string() +
  "</b>Notes</div><div class=\"metric\"><b>" +
  summary.unique_rule_count.to_string() +
  "</b>Rules</div></div></div><div class=\"card\"><h2>Findings</h2>" +
  "<table><thead><tr><th>#</th><th>Level</th><th>Rule</th><th>Location</th><th>Message</th><th>Baseline</th></tr></thead><tbody>" +
  rows +
  "</tbody></table></div></body></html>"
}
