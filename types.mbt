///|
/// A SARIF 2.1.0 log.
///
/// The JSON member `$schema` is exposed as `schema` because `$` is not a
/// valid MoonBit identifier.
pub struct SarifLog {
  version : String
  schema : String?
  runs : Array[Run]
} derive(Debug, Eq)

///|
/// A single analysis run.
pub struct Run {
  tool : Tool
  results : Array[SarifResult]?
  automationDetails : RunAutomationDetails?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Stable identity information for an automated run.
pub struct RunAutomationDetails {
  id : String?
  guid : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Tool metadata attached to a run.
pub struct Tool {
  driver : ToolComponent
  extensions : Array[ToolComponent]?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A component of an analysis tool.
pub struct ToolComponent {
  name : String
  version : String?
  semanticVersion : String?
  informationUri : String?
  rules : Array[ReportingDescriptor]?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Metadata describing a rule emitted by an analysis tool.
pub struct ReportingDescriptor {
  id : String
  name : String?
  shortDescription : Message?
  fullDescription : Message?
  helpUri : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Human-readable SARIF content.
pub struct Message {
  text : String?
  markdown : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A single analysis result.
pub struct SarifResult {
  ruleId : String?
  ruleIndex : Int?
  level : String?
  message : Message
  locations : Array[Location]?
  relatedLocations : Array[Location]?
  partialFingerprints : Map[String, String]?
  fingerprints : Map[String, String]?
  suppressions : Array[Suppression]?
  fixes : Array[Fix]?
  properties : Map[String, Json]?
  baselineState : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A suppression attached to a SARIF result.
pub struct Suppression {
  kind : String
  justification : String?
  location : Location?
  guid : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A proposed fix attached to a SARIF result.
pub struct Fix {
  description : Message?
  artifactChanges : Array[ArtifactChange]?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A change to one artifact proposed by a fix.
pub struct ArtifactChange {
  artifactLocation : ArtifactLocation
  replacements : Array[Replacement]
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A replacement within an artifact.
pub struct Replacement {
  deletedRegion : Region
  insertedContent : ArtifactContent?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A logical or physical result location.
pub struct Location {
  physicalLocation : PhysicalLocation?
  message : Message?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A location in an artifact such as a source file.
pub struct PhysicalLocation {
  artifactLocation : ArtifactLocation?
  region : Region?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Identifies an artifact using a URI.
pub struct ArtifactLocation {
  uri : String?
  uriBaseId : String?
  index : Int?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// A source region. Line and column values are one-based in SARIF.
pub struct Region {
  startLine : Int?
  startColumn : Int?
  endLine : Int?
  endColumn : Int?
  snippet : ArtifactContent?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Embedded artifact content.
pub struct ArtifactContent {
  text : String?
  binary : String?
} derive(Debug, Eq, ToJson, FromJson)
