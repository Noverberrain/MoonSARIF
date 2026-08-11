///|
fn print_help() -> Unit {
  println(
    (
      #|MoonSARIF 0.1.0
      #|
      #|Pure MoonBit SARIF 2.1.0 toolkit.
      #|
      #|Commands available in the first development milestone:
      #|  help       Show this message
      #|  version    Show the current version
      #|
      #|Library APIs already include parse, validate, summarize, filter and merge.
      #|File-oriented CLI commands will be added in the next milestone.
      #|
    ),
  )
}

///|
fn main {
  let args = @env.args()
  match args {
    [_, "version", ..] => println("MoonSARIF 0.1.0")
    [_, "help", ..] | [_] => print_help()
    [_, command, ..] => {
      println("Unknown command: \{command}")
      print_help()
    }
    [] => print_help()
  }
}
