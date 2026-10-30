## Unreleased

- Docs: README with screenshots of the demo app and the console (also on pub.dev); neutral examples ("My App", "items") in the `BrixLogger` docs.

## 1.3.1

- `BrixLogger`: writes to the IDE console through `dart:developer`, one entry at a time, so colours show on iOS too (the iOS console printed the colour codes as text) and other logs cannot land inside a box. `output: print` still prints line by line, e.g. for `flutter run` in a terminal.

## 1.3.0

- `BrixLogger`: one box per message so lines that follow each other never run together; a colour per level (debug grey, info blue, success green, warning yellow, error red) with the level in a coloured badge; the brix mark `▰` and a banner with the brix logo.
- `BrixLogger.success()`: something finished well, logged at info level and shown in green.
- `BrixLogger.width`: width of the box lines (default 64).

## 1.2.0

- `BrixLogger`: a readable console log (time, level, name, short stack traces, start-up banner), off in release builds; `LogLevel`.
- README: logging, the ready `BrixSessionStore` from brix_storage.

## 1.1.1

- README: flow diagrams showing what happens on a tap / in a call.

## 1.1.0

- `Json`: read decoded JSON from any backend into your models without crashes – safe conversions (`"12"` → 12, epoch → `DateTime`), paths (`profile.firstName`), lists, fallbacks, and `Json.onProblem` to see missing or wrong keys while developing.
- `Failure.fieldErrors` and `fieldError(field)`: problems per form field; `ValidationFailure(fieldErrors: …)`.

## 1.0.1

- README: how to use the flows with Riverpod, Bloc, Provider and `setState`.

## 1.0.0

First public release.

- **Core:** `Result` (`Success` / `Failed`), the `Failure` types with default texts (`displayMessage`), `BrixFlow` (immutable state + change stream).
- **Auth:** `LoginFlow` (remember me, double-tap guard, password never trimmed), `SignupFlow`, `OtpVerificationFlow` (resend cooldown, failed attempts, change email), `ForgotPasswordFlow`, `ResetPasswordFlow` (code or link), `PasswordPolicy` with `PasswordRule` labels, `maskIdentifier`.
- **Account:** `SessionFlow` (app start, logout), `ProfileFlow` (load, save, avatar), `ChangePasswordFlow`, `DeleteAccountFlow` (confirm, password or code).
- **App contracts:** `AuthProvider`, `AccountProvider`, `AuthSessionStore`, `AuthNavigator`, `AuthFeedback`, `AuthCapabilities`. Optional methods have default bodies, so later versions do not break your classes.
- **Switch-safe values:** `AuthWarning`, `PasswordRule`, `OtpPurpose` are classes with a default text; switch with a default case.
- **Testing:** `package:brix/testing.dart` – `FakeAuthProvider`, `FakeAccountProvider`, `InMemoryAuthSessionStore`, `RecordingAuthNavigator`, `RecordingAuthFeedback`.
