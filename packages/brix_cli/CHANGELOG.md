## 1.1.1

- Docs: the README tells the brix family story (new app: start with brix_cli; existing app: add the packages you need, each brings the core), with sharper screenshots and a clearer pub.dev description.

## 1.1.0

- One entry point. `flutter run`, F5 and Run Without Debugging just work: debug builds without an API use the local test backend, release builds never contain it (CI checks the release builds on every change).
- The local test backend lives in `lib/dev`. Drop it by deleting that folder and the two marked lines in `main.dart`. Its data now also survives on the web.
- "Skip login" in debug builds opens the home screen as a test user, for working on screens before the login.
- Your API address goes in `lib/config/app_config.dart`, or in `env/staging.json` and `env/production.json` for each build. VS Code has Development, Staging and Production ready.
- Routing on go_router, the router the Flutter architecture guide uses. GetX stays for view models.
- `brix create my_app --org com.mycompany` sets the app id at the start, and `brix id com.mycompany.my_app` changes it later on Android, iOS, macOS and Linux.
- The API's answer shape is one clear line in `lib/config/dependencies.dart`.

## 1.0.0

First release.

- `brix create <app_name>` makes a Flutter app with login, signup with an email code, forgot and reset password, profile, change password, delete account and logout, on brix, brix_getx, brix_network, brix_storage and brix_ui.
- Folders follow the Flutter architecture guide: config, routing, domain models, data repositories and services, and views with view models per feature.
- A local test backend for trying the app without a server (`lib/main_development.dart`). Each device keeps its own data. Release builds start from `lib/main.dart` and never contain it.
- Checks before start: no `API_URL` shows a setup message, and release builds need `https`.
- Apple style screens, a light and dark theme, VS Code run settings and tests.
