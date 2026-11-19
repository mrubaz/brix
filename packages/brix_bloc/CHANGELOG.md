## 1.0.0

- Cubits for every brix screen: `BrixLoginCubit`, `BrixSignupCubit`, `BrixOtpCubit`, `BrixForgotPasswordCubit`, `BrixResetPasswordCubit`, `BrixChangePasswordCubit`, `BrixProfileCubit`, `BrixDeleteAccountCubit`, `BrixSessionCubit`.
- They hold no Flutter objects: screens own their text fields and code boxes and send what is typed (`identifierChanged`, `passwordChanged`, ...), as the Bloc docs recommend.
- Immutable states with `copyWith` and `Equatable`: `BrixLoginState`, `BrixSignupState`, `BrixForgotPasswordState`, `BrixResetPasswordState`, `BrixChangePasswordState`; code screens and profile use brix's own `CodeEntryState` and `ProfileState`.
- `OtpCodeBoxes` for the screen's code boxes.
- Example app: the 14 screen app `brix create` makes, on these cubits.
