# brix_getx example

Login, signup with an email code, forgot / reset password and logout – brix flows on GetX, with an in-memory demo backend (no server).

```
flutter run
```

Demo account `demo@brix.dev` / `Demo@1234`. Every code is `123456`.

Where to look:

| File | What it shows |
|---|---|
| `lib/demo/demo_auth_provider.dart` | the backend adapter – replace it with calls to your API |
| `lib/demo/demo_session_store.dart` | session storage (use secure storage in a real app) |
| `lib/demo/demo_navigator.dart` | how the flows open GetX routes |
| `lib/demo/demo_feedback.dart` | showing backend messages and brix's default texts |
| `lib/routes.dart` | each route's controller and flow |
| `lib/screens/` | screens that are only layout |
