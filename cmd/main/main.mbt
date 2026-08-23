///|
const VERSION : String = "0.3.0"

///|
fn print_help() -> Unit {
  println(
    (
      #|MoonSARIF 0.3.0
      #|
      #|Pure MoonBit SARIF 2.1.0 toolkit.
      #|
      #|Usage:
      #|  moonsarif <command> [arguments] [options]
      #|
      #|Commands:
      #|  validate <file>             Validate a SARIF log
      #|  github-check <file>         Check GitHub Code Scanning compatibility
      #|  summary <file>              Print aggregate result counts
      #|  filter <file> [options]     Keep matching results and print SARIF
      #|  merge <file>... [options]   Concatenate compatible SARIF logs
      #|  deduplicate <file> [options] Remove duplicate findings
      #|  baseline <current> <old>    Compare current results with a baseline
      #|  report <file> [options]      Render a Markdown or HTML report
      #|  version                     Show the current version
      #|  help                        Show this message
      #|
      #|Options:
      #|  --level <level>             Filter by error/warning/note/none
      #|  --rule <rule-id>            Filter by rule id
      #|  --path <text>               Filter by normalized artifact path
      #|  --output <file>             Write output to a file instead of stdout
      #|  --pretty                    Pretty-print JSON output
      #|  --format <markdown|html>    Report output format (default: markdown)
      #|  --baseline <file>           Annotate report findings against a baseline
      #|  --fail-on-new               Fail baseline checks when new findings exist
      #|  --max-new <count>           Allow at most this many new findings
      #|
      #|Exit codes:
      #|  0  success (warnings do not fail validation)
      #|  1  validation found SARIF errors
      #|  2  command or input error
      #|  3  baseline gate rejected new findings
      #|
    ),
  )
}

///|
fn print_version() -> Unit {
  println("MoonSARIF \{VERSION}")
}

///|
fn option_value(args : ArrayView[String], names : ArrayView[String]) -> String? {
  for index, arg in args {
    if names.any(fn(name) { arg == name }) && index + 1 < args.length() {
      return Some(args[index + 1])
    }
  }
  None
}

///|
fn has_option(args : ArrayView[String], name : String) -> Bool {
  args.any(fn(arg) { arg == name })
}

///|
fn int_option(args : ArrayView[String], name : String) -> Int? {
  match option_value(args, [name]) {
    Some(value) => Some(@string.parse_int(value)) catch { _ => None }
    None => None
  }
}

///|
fn positional_args(args : ArrayView[String]) -> Array[String] {
  let values : Array[String] = []
  let mut skip_next = false
  for _, arg in args {
    if skip_next {
      skip_next = false
    } else if arg == "--level" ||
      arg == "--rule" ||
      arg == "--rule-id" ||
      arg == "--path" ||
      arg == "--output" ||
      arg == "--format" ||
      arg == "--baseline" ||
      arg == "--max-new" {
      skip_next = true
    } else if !arg.has_prefix("--") {
      values.push(arg)
    }
  }
  values
}

///|
fn load_log(path : String) -> @moonsarif.SarifLog? {
  try {
    let content = @fs.read_file_to_string(path)
    Some(@moonsarif.parse(content))
  } catch {
    _ => {
      println("error: unable to read or parse SARIF file '\{path}'")
      None
    }
  }
}

///|
fn write_output(content : String, output : String?) -> Bool {
  match output {
    None => {
      println(content)
      true
    }
    Some(path) =>
      try {
        @fs.write_string_to_file(path, content)
        println("wrote \{path}")
        true
      } catch {
        _ => {
          println("error: unable to write output file '\{path}'")
          false
        }
      }
  }
}

///|
fn command_validate(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard paths is [path] else {
    println("error: validate expects exactly one SARIF file")
    print_help()
    return 2
  }
  guard load_log(path) is Some(log) else { return 2 }
  let report = @moonsarif.validate(log)
  let output = report.to_json().stringify(indent=2)
  if !write_output(output, option_value(args, ["--output"])) {
    return 2
  }
  if report.is_valid() {
    0
  } else {
    1
  }
}

///|
fn command_github_check(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard paths is [path] else {
    println("error: github-check expects exactly one SARIF file")
    print_help()
    return 2
  }
  guard load_log(path) is Some(log) else { return 2 }
  let report = @moonsarif.validate_github_compatibility(log)
  let output = report.to_json().stringify(indent=2)
  if !write_output(output, option_value(args, ["--output"])) {
    return 2
  }
  if report.is_valid() {
    0
  } else {
    1
  }
}

///|
fn command_summary(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard paths is [path] else {
    println("error: summary expects exactly one SARIF file")
    print_help()
    return 2
  }
  guard load_log(path) is Some(log) else { return 2 }
  let summary = @moonsarif.summarize(log)
  let pretty = has_option(args, "--pretty")
  let output = summary.to_json().stringify(indent=if pretty { 2 } else { 0 })
  if write_output(output, option_value(args, ["--output"])) {
    0
  } else {
    2
  }
}

///|
fn command_filter(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard paths is [path] else {
    println("error: filter expects exactly one input SARIF file")
    print_help()
    return 2
  }
  guard load_log(path) is Some(log) else { return 2 }
  let filtered = @moonsarif.filter_results(
    log,
    level?=option_value(args, ["--level"]),
    rule_id?=option_value(args, ["--rule", "--rule-id"]),
    path_contains?=option_value(args, ["--path"]),
  )
  let pretty = has_option(args, "--pretty") ||
    option_value(args, ["--output"]) is Some(_)
  let output = @moonsarif.stringify(filtered, pretty~)
  if write_output(output, option_value(args, ["--output"])) {
    0
  } else {
    2
  }
}

///|
fn command_merge(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard !paths.is_empty() else {
    println("error: merge expects at least one input SARIF file")
    print_help()
    return 2
  }
  let logs : Array[@moonsarif.SarifLog] = []
  for path in paths {
    guard load_log(path) is Some(log) else { return 2 }
    logs.push(log)
  }
  guard @moonsarif.merge(logs) is Some(merged) else {
    println("error: cannot merge SARIF logs with different versions")
    return 2
  }
  let pretty = has_option(args, "--pretty") ||
    option_value(args, ["--output"]) is Some(_)
  let output = @moonsarif.stringify(merged, pretty~)
  if write_output(output, option_value(args, ["--output"])) {
    0
  } else {
    2
  }
}

///|

///|
fn command_deduplicate(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard paths is [path] else {
    println("error: deduplicate expects exactly one input SARIF file")
    print_help()
    return 2
  }
  guard load_log(path) is Some(log) else { return 2 }
  let output = @moonsarif.stringify(@moonsarif.deduplicate(log), pretty=true)
  if write_output(output, option_value(args, ["--output"])) {
    0
  } else {
    2
  }
}

///|
fn command_baseline(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard paths is [current_path, baseline_path] else {
    println("error: baseline expects a current log and a baseline log")
    print_help()
    return 2
  }
  guard load_log(current_path) is Some(current) else { return 2 }
  guard load_log(baseline_path) is Some(baseline) else { return 2 }
  let report = @moonsarif.compare_baseline(current, baseline)
  let output = report.to_json().stringify(indent=2)
  if !write_output(output, option_value(args, ["--output"])) {
    return 2
  }
  let max_new = int_option(args, "--max-new")
  if has_option(args, "--max-new") && max_new is None {
    println("error: --max-new expects a non-negative integer")
    return 2
  }
  if max_new is Some(limit) && (limit < 0 || report.new_results > limit) {
    return 3
  }
  if has_option(args, "--fail-on-new") && report.new_results > 0 {
    return 3
  }
  0
}

///|
fn command_report(args : ArrayView[String]) -> Int {
  let paths = positional_args(args)
  guard paths is [path] else {
    println("error: report expects exactly one input SARIF file")
    print_help()
    return 2
  }
  guard load_log(path) is Some(log) else { return 2 }
  let log = match option_value(args, ["--baseline"]) {
    Some(baseline_path) =>
      match load_log(baseline_path) {
        Some(baseline) => @moonsarif.annotate_baseline(log, baseline)
        None => return 2
      }
    None => log
  }
  let format = match option_value(args, ["--format"]) {
    Some(value) => value
    None => "markdown"
  }
  let output = match format {
    "markdown" => @moonsarif.render_markdown(log)
    "html" => @moonsarif.render_html(log)
    _ => {
      println("error: --format must be markdown or html")
      return 2
    }
  }
  if write_output(output, option_value(args, ["--output"])) {
    0
  } else {
    2
  }
}

///|
fn main {
  let args = @env.args()
  let exit_code = match args {
    [_, "version", ..] => {
      print_version()
      0
    }
    [_, "help", ..] | [_] => {
      print_help()
      0
    }
    [_, "validate", .. rest] => command_validate(rest)
    [_, "github-check", .. rest] => command_github_check(rest)
    [_, "summary", .. rest] => command_summary(rest)
    [_, "filter", .. rest] => command_filter(rest)
    [_, "merge", .. rest] => command_merge(rest)
    [_, "deduplicate", .. rest] => command_deduplicate(rest)
    [_, "baseline", .. rest] => command_baseline(rest)
    [_, "report", .. rest] => command_report(rest)
    [_, command, ..] => {
      println("error: unknown command '\{command}'")
      print_help()
      2
    }
    [] => {
      print_help()
      0
    }
  }
  @sys.exit(exit_code)
}
