# brix_ui example

Every brix_ui widget on one screen: a sign-in form, buttons, dialogs, toasts and the loader. Switch **light / dark** and three **brands** live, the widgets stay the same, only the theme changes:

- **Default**: brix's own look.
- **Forest**: own colours, pill buttons with a gradient, underlined fields with the label inside, dialogs as a bottom sheet, toasts at the bottom.
- **Sunset**: sharp corners, the app's own button and toast widgets (`buttonBuilder`, `toastBuilder`), frosted glass, Urdu texts.

```
flutter run
```

See `lib/brands.dart` for the three themes.
