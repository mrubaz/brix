/// How tall a `BrixSheet` opens. An app only picks one, so it is an enum.
enum BrixSheetHeight {
  /// As tall as its content (default), up to almost the full screen.
  content,

  /// Half the screen; longer content scrolls.
  half,

  /// Almost the full screen, like an iOS page sheet.
  full,
}
