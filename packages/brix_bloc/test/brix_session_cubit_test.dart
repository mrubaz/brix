import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_bloc/brix_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthProvider<void, String> auth;
  late RecordingAuthNavigator navigator;
  late BrixSessionCubit<String> cubit;

  setUp(() {
    auth = FakeAuthProvider();
    navigator = RecordingAuthNavigator();
    cubit = BrixSessionCubit(
      SessionFlow(
        auth: auth,
        store: InMemoryAuthSessionStore<String>(),
        navigator: navigator,
        feedback: RecordingAuthFeedback(),
      ),
    );
  });

  tearDown(() => cubit.close());

  test('start opens login when nothing is saved', () async {
    await cubit.start();

    expect(navigator.visits, ['login']);
  });

  test('isLoggingOut follows the flow during logout', () async {
    auth.gate = Completer<void>();

    final logout = cubit.logout();
    expect(cubit.state.isLoggingOut, isTrue);
    auth.gate!.complete();
    await logout;

    expect(cubit.state.isLoggingOut, isFalse);
    expect(navigator.visits, ['login']);
  });

  test('closing disposes the flow', () async {
    final flow = cubit.flow;

    await cubit.close();

    expect(flow.isDisposed, isTrue);
  });
}
