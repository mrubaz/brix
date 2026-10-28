import 'dart:async';

import 'package:meta/meta.dart';

/// Base of every brix flow: holds one immutable state [S] and tells
/// listeners when it changes.
///
/// Pure Dart, so any state library can follow it: GetX copies [state] into
/// `.obs`, a Cubit `emit`s it, a Riverpod notifier sets it, a widget calls
/// `setState`. Listen to [changes]; read [state] for the current value.
abstract class BrixFlow<S> {
  BrixFlow(this._state);

  S _state;
  final StreamController<S> _changes = StreamController<S>.broadcast(
    sync: true,
  );

  S get state => _state;

  /// Every new state, delivered right away (synchronously).
  Stream<S> get changes => _changes.stream;

  bool get isDisposed => _changes.isClosed;

  /// Sets a new state. For subclasses only; ignored after [dispose].
  @protected
  void emit(S state) {
    if (isDisposed) return;
    _state = state;
    _changes.add(state);
  }

  /// Stops all listeners. Call it when the screen that owns the flow closes.
  Future<void> dispose() => _changes.close();
}
