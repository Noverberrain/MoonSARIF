///|
const VERSION : String = "0.1.0"

///|
fn print_help() -> Unit {
  println(
    (
      #|MoonSARIF 0.1.0
      #|
      #|Pure MoonBit SARIF 2.1.0 toolkit.
      #|
      #|Usage:
      #|  moonsarif <command> [arguments] [options]
      #|
      #|Commands:
      #|  validate <file>             Validate a SARIF log
      #|  summary <file>              Print aggregate result counts
      #|  filter <file> [options]     Keep matching results and print SARIF
      #|  merge <file>... [options]   Concatenate compatible SARIF logs
      #|  deduplicate <file> [options] Remove duplicate findings
      #|  baseline <current> <old>    Compare current results with a baseline
      #|  version                     Show the current version
      #|  help                        Show this message
      #|
      #|Options:
      #|  --level <level>             Filter by error/warning/note/none
      #|  --rule <rule-id>            Filter by rule id
      #|  --path <text>               Filter by normalized artifact path
      #|  --output <file>             Write output to a file instead of stdout
      #|  --pretty                    Pretty-print JSON output
      #|
      #|Exit codes:
      #|  0  success (warnings do not fail validation)
      #|  1  validation found SARIF errors
      #|  2  command or input error
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
      arg == "--output" {
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
    [_, "summary", .. rest] => command_summary(rest)
    [_, "filter", .. rest] => command_filter(rest)
    [_, "merge", .. rest] => command_merge(rest)
    [_, "deduplicate", .. rest] => command_deduplicate(rest)
    [_, "baseline", .. rest] => command_baseline(rest)
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
