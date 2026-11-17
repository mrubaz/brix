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
