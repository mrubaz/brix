## 2.0.0

Breaking: the notifiers follow the Riverpod docs and hold no Flutter objects (no form keys, text controllers, focus nodes or code boxes). The screen owns its fields and sends what is typed; the state is immutable (`Equatable`, `copyWith`).

- Removed `BrixAuthFormNotifier`, `BrixCodeEntryNotifier`, `initFields` / `disposeFields` and every `formKey`, `...Controller` and `boxes` field.
- New input methods: `identifierChanged`, `passwordChanged`, `confirmPasswordChanged`, `currentPasswordChanged`, `newPasswordChanged`. Typed values live in the state.
- Code screens pass the code: `verify(code)`, `submit(code)`, `confirm(code)`. `otpLength` gives the box count. Clear your `OtpCodeBoxes` when `failedAttempts` goes up.
- `BrixProfileNotifier.save(update)` takes the app's typed update; `onUserLoaded` and `buildUpdate` are gone. Fill your form when `state.user` first arrives.
- `BrixForgotPasswordNotifier` has its own `BrixForgotPasswordState`.
- Example: `ProviderScope` instead of a global `ProviderContainer`; the login screen fills a prefilled email in `didUpdateWidget`.

Migration: make each screen a `ConsumerStatefulWidget` with its own `GlobalKey<FormState>` and controllers, wire `onChanged` to the new methods, validate the form, then call `login()`, `signup()`, `submit()` and so on.

## 1.0.0

- `BrixAuthFormNotifier`: base Riverpod notifier for a brix form (form key, busy state, flow disposed with the provider).
- `BrixLoginNotifier` and `BrixLoginState`: login with remember me, password visibility and prefill.
- `BrixSessionNotifier`: start and logout on brix `SessionFlow`.
- `BrixCodeEntryNotifier` and `OtpCodeBoxes`: base for code screens (boxes, resend, boxes cleared on a rejected code).
- `BrixOtpNotifier`: signup code, submits on the last digit. State is the flow's `CodeEntryState`.
- `BrixSignupNotifier` and `BrixSignupState`, `BrixForgotPasswordNotifier`, `BrixResetPasswordNotifier` and `BrixResetPasswordState`, `BrixChangePasswordNotifier` and `BrixChangePasswordState`. Unmet password rules live in the state.
- `initFields` / `disposeFields` on the base notifiers for the app's own fields.
- `BrixProfileNotifier`: loads on start, fills the app's form, keeps unsaved typing during an avatar upload. State is the flow's `ProfileState`.
- `BrixDeleteAccountNotifier`: code, confirm and password modes, focus on the first box once the code is sent. `isRequesting` on `CodeEntryState`.
- Example app on a demo backend (login, signup, code, forgot and reset password, logout) with an end-to-end test.
