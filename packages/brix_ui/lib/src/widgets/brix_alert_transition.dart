/// How a `BrixAlert` comes in and goes out. An app only picks one, so it is
/// an enum.
enum BrixAlertTransition {
  /// Fades in with a small grow, like an iOS alert (default).
  scale,

  /// Fades in only.
  fade,

  /// Slides up from below – pairs with a bottom alignment (sheet look).
  slideUp,

  /// Slides down from above – pairs with a top alignment (banner look).
  slideDown,
}
