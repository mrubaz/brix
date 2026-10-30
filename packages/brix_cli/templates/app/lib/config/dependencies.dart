import 'package:brix/account.dart';
import 'package:brix_network/brix_network.dart';
import 'package:brix_storage/brix_storage.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:get/get.dart';

import '../domain/models/profile_update.dart';
import '../domain/models/signup_request.dart';
import '../domain/models/user.dart';
import '../routing/app_navigator.dart';
import 'dev_tools.dart';

/// The app's backend: auth and account. `main.dart` passes your API,
/// `main_development.dart` the local one.
typedef Backend = ({
  AuthProvider<SignupRequest, User> auth,
  AccountProvider<User, ProfileUpdate> account,
});

/// Creates the app-wide services once and registers them with GetX.
/// Screens get their view models from the routes (`routing/app_pages.dart`).
abstract final class Dependencies {
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
    final session = BrixSessionStore<User>(
      storage: storage ?? BrixStorage(),
      userToJson: (user) => user.toJson(),
      userFromJson: (json) => User.fromJson(Json(json)),
    );
    Get.put<AuthSessionStore<User>>(session, permanent: true);
    Get.put<AuthNavigator>(AppNavigator(), permanent: true);
    Get.put<AuthFeedback>(const BrixUiFeedback(), permanent: true);
    if (devTools != null) Get.put<DevTools>(devTools, permanent: true);

    final api = BrixApi(
      baseUrl: apiUrl.isEmpty ? 'https://localhost/' : apiUrl,
      token: () async => (await session.readSession())?.accessToken,
      logger: PrettyNetworkLogger(),
      // A 401 ends the session once, however many calls fail together.
      onUnauthorized: () => sessionFlow().logout(),
    );
    final repositories = backend(api, session);
    Get.put(repositories.auth, permanent: true);
    Get.put(repositories.account, permanent: true);
  }

  static AuthProvider<SignupRequest, User> get auth => Get.find();
  static AccountProvider<User, ProfileUpdate> get account => Get.find();
  static AuthSessionStore<User> get session => Get.find();
  static AuthNavigator get navigator => Get.find();
  static AuthFeedback get feedback => Get.find();

  /// Only while developing; `null` in a release build.
  static DevTools? get devTools =>
      Get.isRegistered<DevTools>() ? Get.find<DevTools>() : null;

  /// App start (splash) and logout.
  static SessionFlow<User> sessionFlow() => SessionFlow(
    auth: auth,
    store: session,
    navigator: navigator,
    feedback: feedback,
  );
}
