## 1.0.3

- Docs: the README tells the brix family story (new app: start with brix_cli; existing app: add the packages you need, each brings the core), with sharper screenshots and a clearer pub.dev description.
- Docs: a step by step guide for adding brix to an app you already have, from your API class to the first screen.
- Docs: README and pub.dev screenshots of the example app (login, live password rules, email code boxes).

## 1.0.2

- README: flow diagrams showing what happens on a tap / in a call.

## 1.0.1

- `package:brix_getx/brix_getx.dart` also exports brix, so one import is enough.

## 1.0.0

First public release.

- Controllers for every brix flow: `BrixLoginController`, `BrixSignupController`, `BrixOtpController`, `BrixForgotPasswordController`, `BrixResetPasswordController`, `BrixChangePasswordController`, `BrixProfileController`, `BrixDeleteAccountController`, `BrixSessionController`.
- Helpers: `OtpCodeBoxes` (one box per digit, paste / autofill, auto submit), `PasswordRulesTracker` (live checklist).
- Example app: login, signup with a code, forgot / reset password, logout on an in-memory demo backend.
