///|
/// A mutable builder for one SARIF analysis log.
pub struct LogBuilder {
  mut tool : ToolComponent
  results : Array[SarifResult]
  mut schema : String?
}

///|
/// Create a builder with a SARIF 2.1.0 tool driver.
pub fn LogBuilder::new(
  tool_name~ : String,
  tool_version? : String = "",
) -> LogBuilder {
  let version = if tool_version.is_empty() { None } else { Some(tool_version) }
  {
    tool: {
      name: tool_name,
      version,
      semanticVersion: None,
      informationUri: None,
      rules: None,
    },
    results: [],
    schema: Some("https://json.schemastore.org/sarif-2.1.0.json"),
  }
}

///|
/// Set the JSON schema URI emitted by the builder.
pub fn LogBuilder::set_schema(self : LogBuilder, schema : String) -> Unit {
  self.schema = Some(schema)
}

///|
/// Add a rule to the tool driver.
pub fn LogBuilder::add_rule(
  self : LogBuilder,
  id~ : String,
  name? : String,
  help_uri? : String,
) -> Unit {
  let descriptor = {
    id,
    name,
    shortDescription: None,
    fullDescription: None,
    helpUri: help_uri,
  }
  let rules = match self.tool.rules {
    Some(rules) => {
      rules.push(descriptor)
      rules
    }
    None => [descriptor]
  }
  self.tool = {
    name: self.tool.name,
    version: self.tool.version,
    semanticVersion: self.tool.semanticVersion,
    informationUri: self.tool.informationUri,
    rules: Some(rules),
  }
}

///|
/// Add a result and return its zero-based index.
pub fn LogBuilder::add_result(
  self : LogBuilder,
  rule_id? : String,
  level? : String,
  message~ : Message,
  location? : Location,
) -> Int {
  let locations = match location {
    Some(value) => Some([value])
    None => None
  }
  let result = {
    ruleId: rule_id,
    ruleIndex: None,
    level,
    message,
    locations,
    relatedLocations: None,
    partialFingerprints: None,
    fingerprints: None,
    suppressions: None,
    fixes: None,
    properties: None,
    baselineState: None,
  }
  self.results.push(result)
  self.results.length() - 1
}

///|
fn LogBuilder::update_result(
  self : LogBuilder,
  result_index : Int,
  update : (SarifResult) -> SarifResult,
) -> Unit {
  self.results[result_index] = update(self.results[result_index])
}

///|
/// Replace the primary locations of a result.
pub fn LogBuilder::set_locations(
  self : LogBuilder,
  result_index : Int,
  locations : Array[Location],
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: Some(locations),
      relatedLocations: result.relatedLocations,
      partialFingerprints: result.partialFingerprints,
      fingerprints: result.fingerprints,
      suppressions: result.suppressions,
      fixes: result.fixes,
      properties: result.properties,
      baselineState: result.baselineState,
    }
  })
}

///|
/// Set related locations for a result.
pub fn LogBuilder::set_related_locations(
  self : LogBuilder,
  result_index : Int,
  locations : Array[Location],
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: result.locations,
      relatedLocations: Some(locations),
      partialFingerprints: result.partialFingerprints,
      fingerprints: result.fingerprints,
      suppressions: result.suppressions,
      fixes: result.fixes,
      properties: result.properties,
      baselineState: result.baselineState,
    }
  })
}

///|
/// Set partial fingerprints for a result.
pub fn LogBuilder::set_partial_fingerprints(
  self : LogBuilder,
  result_index : Int,
  fingerprints : Map[String, String],
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: result.locations,
      relatedLocations: result.relatedLocations,
      partialFingerprints: Some(fingerprints),
      fingerprints: result.fingerprints,
      suppressions: result.suppressions,
      fixes: result.fixes,
      properties: result.properties,
      baselineState: result.baselineState,
    }
  })
}

///|
/// Set fingerprints for a result.
pub fn LogBuilder::set_fingerprints(
  self : LogBuilder,
  result_index : Int,
  fingerprints : Map[String, String],
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: result.locations,
      relatedLocations: result.relatedLocations,
      partialFingerprints: result.partialFingerprints,
      fingerprints: Some(fingerprints),
      suppressions: result.suppressions,
      fixes: result.fixes,
      properties: result.properties,
      baselineState: result.baselineState,
    }
  })
}

///|
/// Set suppressions for a result.
pub fn LogBuilder::set_suppressions(
  self : LogBuilder,
  result_index : Int,
  suppressions : Array[Suppression],
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: result.locations,
      relatedLocations: result.relatedLocations,
      partialFingerprints: result.partialFingerprints,
      fingerprints: result.fingerprints,
      suppressions: Some(suppressions),
      fixes: result.fixes,
      properties: result.properties,
      baselineState: result.baselineState,
    }
  })
}

///|
/// Set fixes for a result.
pub fn LogBuilder::set_fixes(
  self : LogBuilder,
  result_index : Int,
  fixes : Array[Fix],
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: result.locations,
      relatedLocations: result.relatedLocations,
      partialFingerprints: result.partialFingerprints,
      fingerprints: result.fingerprints,
      suppressions: result.suppressions,
      fixes: Some(fixes),
      properties: result.properties,
      baselineState: result.baselineState,
    }
  })
}

///|
/// Set arbitrary SARIF properties for a result.
pub fn LogBuilder::set_properties(
  self : LogBuilder,
  result_index : Int,
  properties : Map[String, Json],
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: result.locations,
      relatedLocations: result.relatedLocations,
      partialFingerprints: result.partialFingerprints,
      fingerprints: result.fingerprints,
      suppressions: result.suppressions,
      fixes: result.fixes,
      properties: Some(properties),
      baselineState: result.baselineState,
    }
  })
}

///|
/// Set the baseline state for a result.
pub fn LogBuilder::set_baseline_state(
  self : LogBuilder,
  result_index : Int,
  baseline_state : String,
) -> Unit {
  self.update_result(result_index, fn(result) {
    {
      ruleId: result.ruleId,
      ruleIndex: result.ruleIndex,
      level: result.level,
      message: result.message,
      locations: result.locations,
      relatedLocations: result.relatedLocations,
      partialFingerprints: result.partialFingerprints,
      fingerprints: result.fingerprints,
      suppressions: result.suppressions,
      fixes: result.fixes,
      properties: result.properties,
      baselineState: Some(baseline_state),
    }
  })
}

///|
/// Finish the log and return the ordinary SARIF data model.
pub fn LogBuilder::finish(self : LogBuilder) -> SarifLog {
  {
    version: "2.1.0",
    schema: self.schema,
    runs: [
      {
        tool: { driver: self.tool, extensions: None },
        results: Some(self.results),
        automationDetails: None,
      },
    ],
  }
}

///|
/// Construct a text SARIF message.
pub fn message_text(text : String) -> Message {
  { text: Some(text), markdown: None }
}

///|
/// Construct a markdown SARIF message.
pub fn message_markdown(markdown : String) -> Message {
  { text: None, markdown: Some(markdown) }
}

///|
/// Construct a suppression for a result.
pub fn make_suppression(
  kind~ : String,
  justification? : String,
  location? : Location,
  guid? : String,
) -> Suppression {
  { kind, justification, location, guid }
}

///|
/// Construct a source location with a one-based start line.
pub fn make_location(
  uri~ : String,
  start_line~ : Int,
  start_column? : Int,
  end_line? : Int,
  end_column? : Int,
) -> Location {
  {
    physicalLocation: Some({
      artifactLocation: Some({ uri: Some(uri), uriBaseId: None, index: None }),
      region: Some({
        startLine: Some(start_line),
        startColumn: start_column,
        endLine: end_line,
        endColumn: end_column,
        snippet: None,
      }),
    }),
    message: None,
  }
}
