import 'package:brix/account.dart';
import 'package:brix_network/brix_network.dart';
import 'package:brix_storage/brix_storage.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/profile_update.dart';
import '../domain/models/signup_request.dart';
import '../domain/models/user.dart';
import '../routing/app_navigator.dart';
import '../routing/app_router.dart';
import 'dev_tools.dart';

/// The app's backend: auth and account. `main.dart` passes your API,
/// `lib/dev` the local one.
typedef Backend = ({
  AuthProvider<SignupRequest, User> auth,
  AccountProvider<User, ProfileUpdate> account,
});

/// Creates the app-wide services once. Each route gives its screen a cubit
/// with `BlocProvider` (`routing/app_router.dart`).
abstract final class Dependencies {
  static late BrixStorage _storage;
  static late AuthSessionStore<User> _session;
  static late GoRouter _router;
  static late AuthNavigator _navigator;
  static late AuthFeedback _feedback;
  static late AuthProvider<SignupRequest, User> _auth;
  static late AccountProvider<User, ProfileUpdate> _account;
  static DevTools? _devTools;

  /// [backend] builds the auth and account repositories. [storage] is
  /// replaced in tests (`BrixStorage(values: MemoryStore(), secrets:
  /// MemoryStore())`). [devTools] only while developing.
  static void init({
    required String apiUrl,
    required Backend Function(BrixApi api, AuthSessionStore<User> session)
    backend,
    BrixStorage? storage,
    DevTools? devTools,
  }) {
    _storage = storage ?? BrixStorage();
    _session = BrixSessionStore<User>(
      storage: _storage,
      userToJson: (user) => user.toJson(),
      userFromJson: (json) => User.fromJson(Json(json)),
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    _router = createAppRouter(navigatorKey);
    _navigator = AppNavigator(_router);
    // Dialogs and toasts open from view models without a BuildContext.
    BrixUi.navigatorKey = navigatorKey;
    _feedback = const BrixUiFeedback();
    _devTools = devTools;

    final api = BrixApi(
      baseUrl: apiUrl.isEmpty ? 'https://localhost/' : apiUrl,
      // How your API answers. `envelope` reads {success, message, data,
      // errors}; there are also `fastApi()`, `djangoRest()` and `custom(...)`.
      reader: const ResponseReader.envelope(),
      token: () async => (await _session.readSession())?.accessToken,
      logger: PrettyNetworkLogger(),
      // A 401 ends the session once, however many calls fail together.
      onUnauthorized: () => sessionFlow().logout(),
    );
    final repositories = backend(api, _session);
    _auth = repositories.auth;
    _account = repositories.account;
  }

  static AuthProvider<SignupRequest, User> get auth => _auth;
  static AccountProvider<User, ProfileUpdate> get account => _account;
  static AuthSessionStore<User> get session => _session;
  static AuthNavigator get navigator => _navigator;
  static GoRouter get router => _router;
  static AuthFeedback get feedback => _feedback;
  static BrixStorage get storage => _storage;

  /// Only while developing; `null` in a release build.
  static DevTools? get devTools => _devTools;

  /// App start (splash) and logout.
  static SessionFlow<User> sessionFlow() => SessionFlow(
    auth: auth,
    store: session,
    navigator: navigator,
    feedback: feedback,
  );
}
