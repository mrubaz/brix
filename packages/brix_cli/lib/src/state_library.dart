/// The state libraries `brix create` can build the app on, in menu order.
enum StateLibrary {
  bloc('Bloc'),
  riverpod('Riverpod'),
  getx('GetX');

  const StateLibrary(this.title);

  /// How the menu and the messages name it.
  final String title;

  /// The `--state` values, for messages: `bloc|riverpod|getx`.
  static String get choices => values.map((state) => state.name).join('|');

  /// The library for a `--state` value, or null.
  static StateLibrary? parse(String value) {
    for (final state in values) {
      if (state.name == value.trim().toLowerCase()) return state;
    }
    return null;
  }
}
