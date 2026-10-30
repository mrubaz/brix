# Screenshots

Renders the images of brix, brix_network and brix_storage from real output. It runs on macOS only, because it uses the system's SF fonts:

```
flutter test --update-goldens
```

Images land in each package's `doc/screenshots/`. brix_ui and the brix_getx example have their own `tool/screenshots_test.dart`.
