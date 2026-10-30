## 1.0.0 (not released yet)

First release.

- `brix create <app_name>` makes a Flutter app with login, signup with an email code, forgot and reset password, profile, change password, delete account and logout, on brix, brix_getx, brix_network, brix_storage and brix_ui.
- Folders follow the Flutter architecture guide: config, routing, domain models, data repositories and services, and views with view models per feature.
- A local test backend for trying the app without a server (`lib/main_development.dart`). Each device keeps its own data. Release builds start from `lib/main.dart` and never contain it.
- Checks before start: no `API_URL` shows a setup message, and release builds need `https`.
- Apple style screens, a light and dark theme, VS Code run settings and tests.
