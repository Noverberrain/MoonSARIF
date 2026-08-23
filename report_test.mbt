///|
let report_log =
  #|{
  #|  "version": "2.1.0",
  #|  "runs": [{
  #|    "tool": { "driver": { "name": "MoonLint" } },
  #|    "results": [{
  #|      "ruleId": "MB001",
  #|      "level": "warning",
  #|      "message": { "text": "unsafe <call> & review" },
  #|      "locations": [{ "physicalLocation": {
  #|        "artifactLocation": { "uri": "src\\main.mbt" },
  #|        "region": { "startLine": 12, "startColumn": 3 }
  #|      }}]
  #|    }]
  #|  }]
  #|}

///|
test "render markdown report with findings" {
  let markdown = @moonsarif.render_markdown(@moonsarif.parse(report_log))
  assert_true(markdown.contains("# MoonSARIF Report"))
  assert_true(markdown.contains("| Results | 1 |"))
  assert_true(markdown.contains("MB001"))
  assert_true(markdown.contains("src/main.mbt:12:3"))
}

///|
test "render html report escapes finding text" {
  let html = @moonsarif.render_html(@moonsarif.parse(report_log))
  assert_true(html.contains("<!doctype html>"))
  assert_true(html.contains("&lt;call&gt; &amp; review"))
  assert_true(html.contains("src/main.mbt:12:3"))
  assert_false(html.contains("unsafe <call> & review"))
}

///|
test "render report preserves baseline annotations" {
  let baseline = @moonsarif.parse(
    (
      #|{
      #|  "version": "2.1.0",
      #|  "runs": [{
      #|    "tool": { "driver": { "name": "MoonLint" } },
      #|    "results": [{
      #|      "ruleId": "MB001",
      #|      "level": "warning",
      #|      "message": { "text": "unsafe <call> & review" },
      #|      "locations": [{ "physicalLocation": {
      #|        "artifactLocation": { "uri": "src/main.mbt" },
      #|        "region": { "startLine": 12, "startColumn": 3 }
      #|      }}]
      #|    }]
      #|  }]
      #|}
    ),
  )
  let log = @moonsarif.annotate_baseline(@moonsarif.parse(report_log), baseline)
  assert_true(@moonsarif.render_markdown(log).contains("| unchanged |"))
}
