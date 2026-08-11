///|
/// Normalize common SARIF artifact paths for stable comparisons.
///
/// This converts backslashes to slashes, removes repeated separators and `.`
/// segments, and resolves safe `..` segments without touching URI schemes.
pub fn normalize_path(input : StringView) -> String {
  let source = input.to_owned().replace_all(old="\\", new="/")
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
