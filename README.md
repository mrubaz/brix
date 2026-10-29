# brix

[![CI](https://github.com/mrubaz/brix/actions/workflows/ci.yml/badge.svg)](https://github.com/mrubaz/brix/actions/workflows/ci.yml)
[![brix](https://img.shields.io/pub/v/brix?label=brix)](https://pub.dev/packages/brix)
[![brix_getx](https://img.shields.io/pub/v/brix_getx?label=brix_getx)](https://pub.dev/packages/brix_getx)
[![brix_network](https://img.shields.io/pub/v/brix_network?label=brix_network)](https://pub.dev/packages/brix_network)
[![brix_storage](https://img.shields.io/pub/v/brix_storage?label=brix_storage)](https://pub.dev/packages/brix_storage)
[![brix_ui](https://img.shields.io/pub/v/brix_ui?label=brix_ui)](https://pub.dev/packages/brix_ui)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**The building blocks every Flutter app needs – ready, tested, and yours to style.**

Every app writes the same things again: login, signup, email codes, password reset, profile, logout, API calls, local storage, error messages, buttons, fields and alerts. brix gives you all of that once, done right, so you only build what makes your app different.

![brix_ui – one kit, your brand](packages/brix_ui/doc/screenshots/your_brand.png)

- 🔌 **Any backend** – REST (Node, FastAPI, Django, Laravel, …), Firebase, Supabase. You write one small adapter.
- 🧩 **Any state management** – the logic is pure Dart. GetX controllers are ready; Riverpod, Bloc, Provider and `setState` work with a few lines.
- 🎨 **Your look** – brix_ui's widgets take your colours, font, shape, texts and icons, in light and dark. Or skip it and use your own widgets: the logic never depends on them.
- 🛡️ **Safe by default** – passwords never trimmed or logged, double taps ignored, secrets in Keychain / Keystore and hidden in logs, one logout for many 401s.
- 🔄 **Updates don't break your app** – new features arrive with defaults; new values work with a default `switch` case.
- 📦 **Take only what you need** – every block is its own package.

## Packages

| Package | What it gives you | Use it when |
|---|---|---|
| [**brix**](packages/brix) | Login, signup, email code, forgot / reset password, app start + logout, profile, change password, delete account. `Result`, `Failure`, `Json`, `BrixLogger`. | Always – it is the core. Pure Dart. |
| [**brix_getx**](packages/brix_getx) | A GetX controller for every brix screen: text fields, form key, loading state, code boxes, password checklist. One import includes brix. | Your app uses GetX. |
| [**brix_network**](packages/brix_network) | REST calls on Dio that return a `Result`; readers for common API shapes, field errors, uploads, downloads, a readable log. | Your backend is a REST API. |
| [**brix_storage**](packages/brix_storage) | Values and secrets (Keychain / Keystore) that survive reinstalls and broken keystores safely; a ready session store for brix. | Always useful – saves writing your own session store. |
| [**brix_ui**](packages/brix_ui) | Buttons, text fields, loader, alerts and toasts from one theme – light and dark, your colours, font, shape, texts and icons. A ready `AuthFeedback`. | You want ready widgets in your own look. |

```
flutter pub add brix_getx brix_network brix_storage brix_ui   # GetX app with a REST backend
flutter pub add brix                                          # any other state library / Firebase / Supabase
```

Your app gets only the packages you add. Examples and the other packages are never built into it.

## Everything included

| Area | What you get |
|---|---|
| Auth | login with remember me, signup, email code (boxes, paste / autofill, resend countdown), forgot / reset password, password rules with a live checklist |
| Account | app start (splash), logout, profile + avatar, change password, delete account with a code |
| Errors | `Result` instead of exceptions; backend messages, else plain default texts; form errors per field (`failure.fieldError('email')`) |
| Network | Dio by default (any client), uploads with progress, file / PDF downloads, cancel, retries only where safe, one logout for many 401s, readers for envelope / FastAPI / Django REST APIs |
| Storage | values + secrets, reinstall-safe Keychain, broken Keystore never crashes, ready session store |
| UI | theme tokens (colours, typography, shape, texts, icons) for light and dark; button, text field, loader, alerts that return a value, toasts; optional frosted glass |
| JSON | `Json` reads any backend's data into models without crashes |
| Logs | readable console for your messages and every API call, secrets hidden, off in release |
| Tests | fakes for every contract (`package:brix/testing.dart`), `MemoryStore`, fake network client examples |
| Updates | switch-safe values and default method bodies – new versions don't break your app |

## How the pieces fit

```mermaid
flowchart LR
    UI["Your screens<br/>(brix_ui widgets or your own)"] --> C["brix_getx controller<br/>(or your Bloc / Riverpod / setState)"]
    C --> F["brix flow<br/>LoginFlow, SignupFlow, …"]
    F --> A["Your adapter<br/>AuthProvider / AccountProvider"]
    A --> N["brix_network<br/>BrixApi (Dio)"]
    A --> S["Firebase / Supabase SDK"]
    N --> B[("Your REST API")]
    F --> ST["brix_storage<br/>BrixSessionStore (or your own)"]
    ST --> K[("Keychain / Keystore<br/>+ preferences")]
    F --> NAV["Your navigator<br/>AuthNavigator"]
    F --> FB["Alerts and toasts<br/>BrixUiFeedback (or your own)"]
```

You write the small classes once (backend, navigation); storage and alerts come ready with `brix_storage` and `brix_ui`. Every flow uses them. `BrixLogger` (in brix) and the network log give one readable console.

## A login in a few lines (GetX + REST)

```dart
// 1. The API, once.
final api = BrixApi(
  baseUrl: 'https://api.example.com/v1/',
  token: () => storage.readToken(),
  onUnauthorized: () => session.logout(),
);

// 2. Your backend adapter.
class MyAuth extends AuthProvider<SignupBody, User> {
  @override
  AuthCapabilities get capabilities => const AuthCapabilities(otpAfterSignup: true);

  @override
  Future<Result<AuthSession<User>>> login({
    required String identifier,
    required String password,
  }) => api.post(
    'auth/login',
    body: {'email': identifier, 'password': password},
    parse: (data) => AuthSession(
      accessToken: data.string('token'),
      user: User.fromJson(data.child('user')),
    ),
  );

  @override
  Future<Result<void>> logout() => api.post('auth/logout');
}

// 3. Where the session lives (tokens in Keychain / Keystore).
final store = BrixSessionStore<User>(
  storage: BrixStorage(),
  userToJson: (user) => user.toJson(),
  userFromJson: User.fromJson,
);

// 4. The screen's controller – alerts and toasts from brix_ui.
Get.put(BrixLoginController<User>(LoginFlow(
  provider: MyAuth(),
  store: store,
  navigator: MyNavigator(),
  feedback: const BrixUiFeedback(),
)));
```

```dart
// 5. The screen.
BrixTextField(controller: c.identifierController, label: 'Email', isRequired: true),
BrixTextField(controller: c.passwordController, label: 'Password', isPassword: true),
Obx(() => BrixButton(label: 'Log in', isLoading: c.isSubmitting.value, onPressed: c.login)),
```

Remember me, the double-tap guard, saving the session, error alerts and opening home are done.

## Your look, light and dark

brix_ui reads everything from one `BrixTheme`, so the same widgets look like your app – and dark mode needs no widget change.

```dart
MaterialApp(
  theme: BrixTheme.light(colors: const BrixColors.light(primary: brand)).toThemeData(),
  darkTheme: BrixTheme.dark(colors: const BrixColors.dark(primary: brand)).toThemeData(),
);
```

![Light and dark](packages/brix_ui/doc/screenshots/light_dark.png)

Alerts are a solid card on a dimmed screen, so they read on any background – and they open from a controller:

![Alerts](packages/brix_ui/doc/screenshots/alerts.png)

More – buttons, text fields, toasts, your own texts and icons – in the [brix_ui README](packages/brix_ui).

## Readable console

`BrixLogger` (brix) for your own messages, `PrettyNetworkLogger` (brix_network) for every API call – both off in release builds, secrets hidden.

```dart
final log = BrixLogger(name: 'My App');
log.error('Saving failed', error: error, stackTrace: stackTrace);
```

```
╭─ ▰ ERROR · My App ───────────────────────────── 14:32:07.210
│ Saving failed
│ ↳ Bad state: boom
│   #0 SaveFlow.run (save_flow.dart:42)
╰───────────────────────────────────────────────────────────────
╭─ ▰ POST v1/auth/login ─────────────────────────── 200 · 312 ms
│ → {"email": "ada@brix.dev", "password": "••••"}
│ ← {"success": true, "message": "Welcome back!", …}
╰───────────────────────────────────────────────────────────────
```

One box per message, so lines never run together. Each level has its colour: debug grey, info blue, success green, warning yellow, error red.

## Examples

| Example | Shows |
|---|---|
| [Flutter demo app](packages/brix_getx/example) | Login, signup with an email code, forgot / reset password, logout – on an in-memory backend, runs without a server (`demo@brix.dev` / `Demo@1234`, code `123456`) |
| [brix in plain Dart](packages/brix/example/main.dart) | A login without Flutter or a state library |
| [brix_network](packages/brix_network/example/main.dart) | Loading a list from a public REST API into models |
| [brix_storage](packages/brix_storage/example/main.dart) | Saving a value and a secret |
| [brix_ui example app](packages/brix_ui/example) | Every widget on one screen – light / dark and three brands switched live (style settings only, and own builders) |
| [brix_ui screenshots](packages/brix_ui/tool/screenshots_test.dart) | Every widget in light, dark and three brands – the images on this page come from it |

## Quality

- Every flow, controller, network piece and widget has tests. CI checks format, analysis (no infos) and tests of every package and example on each push.
- The screenshots are rendered from the real widgets, not drawn.
- Values you switch over are classes, not enums – see [updates never break your app](packages/brix#updates-never-break-your-app).
- MIT licensed.

## Develop

```
git clone https://github.com/mrubaz/brix.git
cd brix/packages/brix && dart pub get && dart test
cd ../brix_network && dart pub get && dart test
cd ../brix_storage && flutter pub get && flutter test
cd ../brix_getx && flutter pub get && flutter test
cd ../brix_ui && flutter pub get && flutter test
```

Each package's `pubspec_overrides.yaml` points it at the brix in this repo, so they are developed together. New brix_ui screenshots: `flutter test tool/screenshots_test.dart --update-goldens` in `packages/brix_ui`.

Issues and ideas: [GitHub issues](https://github.com/mrubaz/brix/issues).
