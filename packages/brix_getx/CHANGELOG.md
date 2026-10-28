## 1.0.0

First public release.

- Controllers for every brix flow: `BrixLoginController`, `BrixSignupController`, `BrixOtpController`, `BrixForgotPasswordController`, `BrixResetPasswordController`, `BrixChangePasswordController`, `BrixProfileController`, `BrixDeleteAccountController`, `BrixSessionController`.
- Helpers: `OtpCodeBoxes` (one box per digit, paste / autofill, auto submit), `PasswordRulesTracker` (live checklist).
- Example app: login, signup with a code, forgot / reset password, logout on an in-memory demo backend.
