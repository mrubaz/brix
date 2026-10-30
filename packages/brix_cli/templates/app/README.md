# brix_app

Made with [brix](https://github.com/mrubaz/brix). Login, signup with an email code, forgot and reset password, profile, change password, delete account and logout work out of the box.

## Run

```
flutter run
```

Or press F5 (or Run Without Debugging) in VS Code. Until you add your API, debug runs use a test backend that lives on this device:

- Log in with `demo@brix.dev` and `Demo@1234`. Every code is `123456`.
- "Skip login" opens the home screen right away, handy while you build other screens.
- "Reset local backend" starts this device over. Every device keeps its own test data.

## Add your API

Write its address once in `lib/config/app_config.dart`:

```dart
static const _apiUrl = 'https://your.api/v1/';
```

Different addresses for staging and production? Put them in `env/staging.json` and `env/production.json`. In VS Code pick Staging or Production in Run and Debug, or on the command line:

```
flutter run --dart-define-from-file=env/staging.json
```

Then match the endpoints and fields to your backend in `lib/data/repositories/auth_repository_remote.dart`, `account_repository_remote.dart` and `User.fromJson`. If your API answers in another shape than `{success, message, data, errors}`, change the `reader` line in `lib/config/dependencies.dart`.

## Safe by design

- The test backend runs only in debug builds without an API. The compiler leaves it out of release builds, so its accounts, codes and buttons are not in your store app at all.
- A release build without an API shows a short setup message instead of a login, and it only accepts an `https` address.
- Tokens are kept in the Keychain / Keystore, and logs are off in release builds.

## Bringing your own login

Delete the `lib/dev` folder and the two lines marked `local test backend` in `lib/main.dart`. Nothing else uses them. Your own login screen replaces `lib/ui/auth/widgets/login_screen.dart`.

## The app id

It starts as `com.example.brix_app`. Change it on every platform with one command, run inside the app:

```
brix id com.mycompany.brix_app
```

## Where things are

Folders follow the [Flutter architecture guide](https://docs.flutter.dev/app-architecture/case-study), with views and view models for each feature.

| Folder | What lives there |
|---|---|
| `lib/main.dart` | starts the app |
| `lib/config/` | your API address, and the services made once |
| `lib/routing/` | every screen's address (go_router) and its view model |
| `lib/domain/models/` | your data types (`User`, `SignupRequest`, `ProfileUpdate`) |
| `lib/data/repositories/` | your API calls |
| `lib/ui/core/` | theme and shared widgets |
| `lib/ui/<feature>/` | `widgets/` (screens) and `view_models/` |
| `lib/dev/` | the test backend for debug builds |
| `env/` | API addresses per build |
| `test/` | mirrors `lib/` |

## Make it yours

- Look: `lib/ui/core/themes/theme.dart` sets colours, font, shape, texts and icons for every [brix_ui](https://pub.dev/packages/brix_ui) widget.
- First screen: `lib/ui/home/widgets/home_screen.dart`.

The logic behind the screens (forms, loading, double taps, the session, errors) comes from the brix packages and gets better with `flutter pub upgrade`.
