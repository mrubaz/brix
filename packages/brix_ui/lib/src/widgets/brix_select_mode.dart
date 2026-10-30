/// How a `BrixSelect` shows its options. An app only picks one, so it is an
/// enum.
enum BrixSelectMode {
  /// A menu for up to six options, a sheet for more (default).
  auto,

  /// A menu that opens under the field, like an iOS pull-down menu.
  menu,

  /// A `BrixSheet` with the options as a list.
  sheet,
}
