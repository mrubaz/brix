# brix_cli

[![brix](https://img.shields.io/pub/v/brix?label=brix)](https://pub.dev/packages/brix)
[![brix_getx](https://img.shields.io/pub/v/brix_getx?label=brix_getx)](https://pub.dev/packages/brix_getx)
[![brix_network](https://img.shields.io/pub/v/brix_network?label=brix_network)](https://pub.dev/packages/brix_network)
[![brix_storage](https://img.shields.io/pub/v/brix_storage?label=brix_storage)](https://pub.dev/packages/brix_storage)
[![brix_ui](https://img.shields.io/pub/v/brix_ui?label=brix_ui)](https://pub.dev/packages/brix_ui)
[![brix_cli](https://img.shields.io/pub/v/brix_cli?label=brix_cli)](https://pub.dev/packages/brix_cli)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/mrubaz/brix/blob/main/LICENSE)

Make a new Flutter app that already works: login, signup with an email code, forgot and reset password, profile, change password, delete account and logout. It comes with a theme, API calls, safe storage and tests, all built on [brix](https://github.com/mrubaz/brix).

![Login, signup and email code screens](doc/screenshots/app_sign_in.png)

![Home, profile and delete account screens](doc/screenshots/app_account.png)

## Get started

1. Install the command once:

   ```
   dart pub global activate brix_cli
   ```

2. Make an app. Use lowercase letters, digits and underscores for the name:

   ```
   brix create my_app
   ```

   ![brix create in the terminal](doc/screenshots/terminal.png)

3. Run it on the local test backend. You need no server for this:

   ```
   cd my_app
   flutter run -t lib/main_development.dart
   ```

   Log in with `demo@brix.dev` and `Demo@1234`. Every code is `123456`.

4. Point it at your API when you are ready:

   ```
   flutter run --dart-define=API_URL=https://your.api/v1/
   ```

   The endpoints live in `lib/data/repositories/auth_repository_remote.dart` and `account_repository_remote.dart`. Change the paths and fields there to match your backend.

The app id starts as `com.example.my_app`. Change it before you publish.

## What is inside

The folders follow the [Flutter architecture guide](https://docs.flutter.dev/app-architecture/case-study), with views and view models for each feature.

![The folders of a new app](doc/screenshots/folders.png)

Each screen is a short layout. The logic behind it (forms, loading, double taps, the session, error messages) comes from the brix packages, so it gets better when you run `flutter pub upgrade`, and none of it has to be copied into your app.

## The local test backend

`main_development.dart` runs the app against a small backend that lives on the device. It saves its accounts in a file, so the app behaves like it would with a real server: sign up, verify, log in, change your name or password, delete the account.

Every device keeps its own copy. If two people test with the demo account and one of them changes the password or deletes the account, the other device is not affected. "Reset local backend" on the login screen starts that device over.

## Safe for release

The local backend can never end up in your store app:

- Release builds start from `lib/main.dart`, which does not import the local backend. Its accounts, code and reset button are not in the release app at all.
- `main_development.dart` stops right away if someone builds a release from it.
- Without `API_URL` the app shows a short setup message instead of a login screen, and a release build only accepts an `https` address.
- On every change, our CI makes a new app, builds it for release and checks that no test account is inside.

If you no longer want the local backend, delete `lib/main_development.dart`, the two `*_local.dart` repositories, `lib/data/services/local_accounts_service.dart` and `test/app_test.dart`. Nothing else uses them.

## Commands

```
brix create <app_name>   Make a new app
brix --version
brix --help
```

MIT licensed.

## The brix packages

brix_cli is one part of [brix](https://github.com/mrubaz/brix). Take only the packages you need.

| Package | Version | What it does |
|---|---|---|
| [brix](https://pub.dev/packages/brix) | [![pub](https://img.shields.io/pub/v/brix?label=)](https://pub.dev/packages/brix) | The logic: auth, account, `Result`, `Json`, `BrixLogger` |
| [brix_getx](https://pub.dev/packages/brix_getx) | [![pub](https://img.shields.io/pub/v/brix_getx?label=)](https://pub.dev/packages/brix_getx) | GetX controllers for every brix screen |
| [brix_network](https://pub.dev/packages/brix_network) | [![pub](https://img.shields.io/pub/v/brix_network?label=)](https://pub.dev/packages/brix_network) | REST calls that return a `Result` |
| [brix_storage](https://pub.dev/packages/brix_storage) | [![pub](https://img.shields.io/pub/v/brix_storage?label=)](https://pub.dev/packages/brix_storage) | Values, secrets and a session store |
| [brix_ui](https://pub.dev/packages/brix_ui) | [![pub](https://img.shields.io/pub/v/brix_ui?label=)](https://pub.dev/packages/brix_ui) | Buttons, fields, select, dialogs, sheets, toasts |
| [brix_cli](https://pub.dev/packages/brix_cli) | [![pub](https://img.shields.io/pub/v/brix_cli?label=)](https://pub.dev/packages/brix_cli) | `brix create my_app`: a new app on all of them |
