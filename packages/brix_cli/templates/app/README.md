# brix_app

Made with [brix](https://github.com/mrubaz/brix). Login, signup with an email code, forgot and reset password, profile, change password, delete account and logout work out of the box.

## Run

**Without an API (local test backend):**

```
flutter run -t lib/main_development.dart
```

Login with `demo@brix.dev` / `Demo@1234`, every code is `123456`. The data lives on this device only: what one tester changes never reaches another device. "Reset local backend" on the login screen starts over.

**On your API:**

```
flutter run --dart-define=API_URL=https://your.api/v1/
```

In VS Code both are ready in Run and Debug.

## Safe by design

- Release builds start from `lib/main.dart`, which never imports the local backend. Its accounts, code and reset button are not in a release app at all.
- `lib/main_development.dart` stops at once in a release build.
- Without `API_URL` the app shows a setup message instead of a login. A release build needs an `https` address.
- Tokens are kept in the Keychain / Keystore, logs are off in release builds.

## Where things are

Folders follow the [Flutter architecture guide](https://docs.flutter.dev/app-architecture/case-study) (MVVM).

| Folder | What lives there |
|---|---|
| `lib/main.dart` | the real app on your API (release builds) |
| `lib/main_development.dart` | the app on the local test backend |
| `lib/config/` | `app_config.dart` (API URL checks), `dependencies.dart` (services, created once) |
| `lib/routing/` | route names, pages with their view models, navigation |
| `lib/domain/models/` | your data types (`User`, `SignupRequest`, `ProfileUpdate`) |
| `lib/data/repositories/` | `*_remote.dart`: your API's endpoints; `*_local.dart`: the local test backend |
| `lib/data/services/` | where the local test backend keeps its data |
| `lib/ui/core/` | theme and shared widgets |
| `lib/ui/<feature>/` | `widgets/` (screens) and `view_models/` |
| `test/` | mirrors `lib/` |

## Make it yours

- **Look:** `lib/ui/core/themes/theme.dart`: colours, font, shape, texts, icons for every [brix_ui](https://pub.dev/packages/brix_ui) widget.
- **Your API:** change the paths and fields in `auth_repository_remote.dart`, `account_repository_remote.dart` and `User.fromJson`.
- **Your first screen:** `lib/ui/home/widgets/home_screen.dart`.

## Before you release

1. Build from `lib/main.dart` with your `https` API: `flutter build apk --dart-define=API_URL=https://your.api/v1/`
2. Change the app id `com.example.brix_app` (Android `build.gradle.kts`, iOS project).
3. Hide the code's names: add `--obfuscate --split-debug-info=build/symbols`.

The logic (forms, loading, double-tap guard, session, errors) comes from the brix packages and updates with `flutter pub upgrade`.
