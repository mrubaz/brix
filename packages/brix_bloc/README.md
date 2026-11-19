# brix_bloc

> Part of the [brix](https://github.com/mrubaz/brix) family. It brings the core, [brix](https://pub.dev/packages/brix), with it.

Cubits for [brix](https://pub.dev/packages/brix): one for every account screen. Each holds an immutable state and the methods a screen calls. They hold no Flutter objects, as the Bloc docs recommend: the screen owns its text fields and sends what is typed.

| Cubit | State | Screen |
|---|---|---|
| `BrixLoginCubit` | `BrixLoginState` | login, remember me, email pre-fill |
| `BrixSignupCubit` | `BrixSignupState` | signup (you add your own values and build the request) |
| `BrixOtpCubit` | `CodeEntryState` | code after signup |
| `BrixForgotPasswordCubit` | `BrixForgotPasswordState` | forgot password |
| `BrixResetPasswordCubit` | `BrixResetPasswordState` | code and new password |
| `BrixChangePasswordCubit` | `BrixChangePasswordState` | change password |
| `BrixProfileCubit` | `ProfileState` | profile load, save and avatar |
| `BrixDeleteAccountCubit` | `CodeEntryState` | delete account with a code |
| `BrixSessionCubit` | `SessionState` | splash (`start`) and logout |

## Install

```
flutter pub add brix_bloc flutter_bloc
```

## A screen

```dart
BlocProvider(
  create: (_) => BrixLoginCubit<User>(LoginFlow(/* your adapters */)),
  child: const LoginScreen(),
)
```

```dart
BrixTextField(
  label: 'Email',
  onChanged: context.read<BrixLoginCubit<User>>().identifierChanged,
)
// After the form is valid:
context.read<BrixLoginCubit<User>>().login();
```

Code screens keep their `OtpCodeBoxes` in the widget, pass the typed code to `verify`, `submit` or `confirm`, and clear the boxes when `failedAttempts` goes up.

## Example app

[`example/`](example) is the full app `brix create` makes (14 screens on a test backend), on these cubits. Demo account `demo@brix.dev` / `Demo@1234`, every code `123456`.

## License

MIT
