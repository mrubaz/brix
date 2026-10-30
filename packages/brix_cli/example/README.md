# Example

```
dart pub global activate brix_cli
brix create my_app
cd my_app
flutter run -t lib/main_development.dart
```

Log in with `demo@brix.dev` and `Demo@1234`. Every code is `123456`.

When your API is ready:

```
flutter run --dart-define=API_URL=https://your.api/v1/
```
