# brix_riverpod example

Login, signup with an email code, forgot / reset password and logout: brix flows on Riverpod, with an in-memory demo backend (no server).

```
flutter run
```

Demo account `demo@brix.dev` / `Demo@1234`. Every code is `123456`.

Where to look:

| File | What it shows |
|---|---|
| `lib/demo/demo_auth_provider.dart` | the backend adapter; replace it with calls to your API |
| `lib/demo/demo_session_store.dart` | session storage (use secure storage in a real app) |
| `lib/demo/demo_navigator.dart` | how the flows open Flutter named routes |
| `lib/providers.dart` | the adapters (brix_ui's `BrixUiFeedback` for dialogs and toasts) and one auto-dispose provider per screen |
| `lib/notifiers/app_notifiers.dart` | each notifier only says where its flow comes from |
| `lib/screens/` | screens that are only layout, on brix_ui widgets (the same look as the app brix_cli makes) |
