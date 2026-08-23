// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "Noverberrain/moonsarif"

version = "0.3.0"

readme = "README.mbt.md"

repository = "https://github.com/Noverberrain/MoonSARIF"

license = "Apache-2.0"

keywords = [ "sarif", "static-analysis", "code-scanning", "developer-tools" ]

preferred_target = "wasm-gc"

description = "Pure MoonBit toolkit for parsing, validating, filtering and summarizing SARIF 2.1.0 logs"

import {
  "moonbitlang/x@0.5.1",
}
