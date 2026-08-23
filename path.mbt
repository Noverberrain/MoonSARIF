///|
fn normalize_path_part(source : String) -> String {
  let segments : Array[String] = []
  for part in source.split("/") {
    let segment = part.to_owned()
    if segment.is_empty() || segment == "." {
      continue
    }
    if segment == ".." {
      if !segments.is_empty() && segments.last() != Some("..") {
        ignore(segments.pop())
      } else {
        segments.push(segment)
      }
    } else {
      segments.push(segment)
    }
  }
  let prefix = if source.has_prefix("/") { "/" } else { "" }
  prefix + segments.join("/")
}

///|
/// Normalize common SARIF artifact paths for stable comparisons.
///
/// This converts backslashes to slashes, removes repeated separators and `.`
/// segments, resolves safe `..` segments, and preserves URI schemes such as
/// `https://` and `file://`.
pub fn normalize_path(input : StringView) -> String {
  let source = input.to_owned().replace_all(old="\\", new="/")
  match source.split_once("://") {
    Some((scheme, rest)) =>
      scheme.to_owned() + "://" + normalize_path_part(rest.to_owned())
    None => normalize_path_part(source)
  }
}
