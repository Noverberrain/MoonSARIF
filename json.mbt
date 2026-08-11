///|
struct WireSarifLog {
  version : String
  runs : Array[Run]
} derive(FromJson)

///|
pub impl FromJson for SarifLog with fn from_json(json, path) {
  let wire : WireSarifLog = @json.from_json(json, path~)
  let schema = match json {
    Object(fields) =>
      match fields.get("$schema") {
        None => None
        Some(value) =>
          Some(@json.from_json(value, path=path.add_key("$schema")))
      }
    _ => None
  }
  { version: wire.version, schema, runs: wire.runs }
}

///|
pub impl ToJson for SarifLog with fn to_json(self) {
  let fields : Map[String, Json] = {
    "version": self.version.to_json(),
    "runs": self.runs.to_json(),
  }
  match self.schema {
    Some(schema) => fields["$schema"] = schema.to_json()
    None => ()
  }
  Json::object(fields)
}

///|
/// Parse a SARIF JSON string into a typed log.
///
/// JSON syntax failures and typed decoding failures are propagated to the
/// caller, preserving their detailed paths.
pub fn parse(input : StringView) -> SarifLog raise {
  let json = @json.parse(input)
  @json.from_json(json)
}

///|
/// Serialize a typed SARIF log as JSON.
pub fn stringify(log : SarifLog, pretty? : Bool = false) -> String {
  if pretty {
    log.to_json().stringify(indent=2)
  } else {
    log.to_json().stringify()
  }
}
