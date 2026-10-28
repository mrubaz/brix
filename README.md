# Brix

[![CI](https://github.com/mrubaz/brix/actions/workflows/ci.yml/badge.svg)](https://github.com/mrubaz/brix/actions/workflows/ci.yml)

Ready-made building blocks every app needs. Import a block, write a small adapter for your backend, build your own UI.

```
brix/
  packages/
    brix/         pure Dart core – no Flutter, no state library (works with GetX, Bloc, Riverpod, Provider, setState)
    brix_getx/    GetX wrappers (controllers with text fields, form key, Rx state)
    brix_network/ REST calls (Dio by default), every call a Result
```

Each state library gets its own small wrapper package next to `brix`; an app uses only the one it needs. `package:brix/testing.dart` holds fakes for tests.

**Install:** `flutter pub add brix brix_getx` (or only `brix` with another state library).

**Start here:** [packages/brix](packages/brix) (what it is, install, quick start) · [packages/brix_getx](packages/brix_getx) (GetX controllers) · [packages/brix_network](packages/brix_network) (REST calls) · [example app](packages/brix_getx/example) (runs without a server).

## Blocks

| Block | Status | Import |
|---|---|---|
| core | `Result`, `Failure`, `Json`, `BrixFlow` | `package:brix/core.dart` |
| auth | login, signup, forgot, reset, OTP flows, `PasswordPolicy` (step 6) | `package:brix/auth.dart` |
| account | `AccountProvider`, `SessionFlow` (app start, logout), `ProfileFlow`, `ChangePasswordFlow`, `DeleteAccountFlow` | `package:brix/account.dart` |
| testing | fakes for tests | `package:brix/testing.dart` |
| network | `BrixApi` (Dio default), response readers (envelope, FastAPI, Django REST), pretty logger, uploads, 401 logout | `package:brix_network/brix_network.dart` |
| brix_getx | login, signup, forgot, reset, OTP, change password, session, profile, delete account controllers; `OtpCodeBoxes`, `PasswordRulesTracker` | `package:brix_getx/brix_getx.dart` |

## Updates never break your app

Values you `switch` over (`AuthWarning`, `PasswordRule`, `OtpPurpose`) are classes, not enums. Always add a default case – new values from a brix update then just work:

```dart
String warningText(AuthWarning warning) => switch (warning) {
  AuthWarning.otpIncomplete => 'Please enter the full code.', // your wording
  _ => warning.message, // brix's default English text
};
```

Your own checks can use the same type: `const AuthWarning('termsNotAccepted', 'Accept the terms first.')`.

## Develop

CI (`.github/workflows/ci.yml`) runs the same checks on every push and pull request: format, `analyze --fatal-infos`, tests – for both packages. `main` only merges when both pass.

```
cd packages/brix
dart pub get
dart analyze --fatal-infos
dart test
```

`packages/brix_getx/pubspec_overrides.yaml` points brix_getx at the brix in this repo, so both are developed together. An app can do the same with its own (git-ignored) `pubspec_overrides.yaml`:

```yaml
dependency_overrides:
  brix:
    path: ../brix/packages/brix
```
