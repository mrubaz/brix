/// The edge of a `BrixTextField`. An app only picks one, so it is an enum.
enum BrixFieldBorder {
  /// A rounded box all around (default).
  outline,

  /// A line under the text only (Material / iOS settings look).
  underline,

  /// No edge – use with a fill colour.
  none,
}
