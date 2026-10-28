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
