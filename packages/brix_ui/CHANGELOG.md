## 1.1.1

- Docs: the README tells the brix family story (new app: start with brix_cli; existing app: add the packages you need, each brings the core), with sharper screenshots and a clearer pub.dev description.

## 1.1.0

- `BrixAlert` is now `BrixDialog`, the name Flutter developers look for. `BrixAlertButton`, `BrixAlertStyle`, `BrixAlertData`, `BrixAlertTransition` and the theme's `alert` / `alertBuilder` follow (`BrixDialogButton`, `BrixDialogStyle`, `BrixDialogData`, `BrixDialogTransition`, `dialog`, `dialogBuilder`). Please use 1.1.0 instead of 1.0.0.
- New `BrixSheet`: a bottom sheet with a grabber, an optional title and any content. It opens as tall as its content or at half or full height, closes when dragged down or tapped outside, and returns a value. `BrixSheetStyle` and `sheetBuilder` change its look.
- New `BrixSelect<T>`: a typed dropdown that matches the text fields. A few options open in a menu, many in a sheet, with a tick on the chosen one. Works in a `Form` with a required check. `BrixSelectStyle` and `selectBuilder` change its look.
- `BrixUiTexts.selectHint`, `BrixUiIcons.selectChevron` and `BrixUiIcons.selected` for the new select.
- New screenshots on an iPhone, made from the real widgets.

## 1.0.0

First release.

- `BrixTheme`: colours, text styles and shape as theme tokens, with light and dark defaults. Read with `context.brix`; without setup the kit follows the app's brightness. `toThemeData()` builds a matching Material theme. Theme changes animate.
- `BrixButton` (filled, optional gradient), `BrixButton.outlined`, `BrixButton.destructive`: colours and size from the theme, spinner while loading (same size, taps ignored), faded when disabled, light haptic and a small press scale, label shown as written.
- `BrixLoader`: centred iOS-style spinner in the theme's quiet text colour.
- `BrixTextField`: label above with `*` when required (built-in empty check, own message), password with show / hide button (no autocorrect, never trimmed), Next moves to the next field, Done and a tap outside close the keyboard, `validator` or outside `errorText`, autofill hints, read-only / disabled looks; colours and height from the theme; the label is read with the field by screen readers.
- `BrixAlert`: centred card on a dimmed screen (reads on any background). `BrixAlert.show<T>()` opens it as a dialog and returns the tapped `BrixAlertButton` value (two buttons side by side, more stacked; filled / outlined / destructive). `BrixAlert.warning()` / `.error()` show an OK alert above everything that stays while the screen underneath changes; a new one replaces the open one; long messages scroll.
- `BrixToast.success()`: slides in at the top, hides after 3 s (or tap / swipe up), never blocks the screen, announced to screen readers.
- `BrixTheme.glass`: frosted alerts and toasts as an option (off by default).
- `BrixUi.navigatorKey`: lets alerts and toasts open without a `BuildContext` (GetX: `Get.key`); every call also takes a `context`.
- `BrixUiFeedback`: a ready brix `AuthFeedback`: failures and warnings as alerts, success as a toast.
- `BrixUiTexts` / `BrixUiIcons` in `BrixTheme`: every text (OK, alert titles, password button, required error) and icon brix_ui shows on its own can be replaced, any language, any icon set. `BrixIcon` takes a Flutter icon or any widget (`BrixIcon.custom`, e.g. an SVG) and tints it.
- Screenshots on pub.dev and in the README, rendered from the real widgets (`tool/screenshots_test.dart`).
- `BrixButtonStyle` (`BrixTheme.button` for every button, `BrixButton.style` for one): height, radius, padding, text style, capitals, icon size and gap, press scale, disabled opacity, outline width, gradient, haptics.
- `buttonBuilder` (`BrixTheme.buttonBuilder` or `BrixButton.builder`): draw a completely own button from `BrixButtonData`; brix keeps the double-tap guard, haptic and loading state. Alerts use it too. `BrixButtonVariant` is switch-safe (a class, not an enum).
- `BrixTextFieldStyle` (`BrixTheme.textField` for every field, `BrixTextField.style` for one): outline / underline / no edge (`BrixFieldBorder`), fill, radius, height, padding, edge widths, label inside or above, label gap, text / label / hint styles.
- `textFieldBuilder` (`BrixTheme.textFieldBuilder` or `BrixTextField.builder`): draw a completely own field from `BrixTextFieldData` (controller, focus, validator, password state, keyboard actions); brix keeps the logic.
- `BrixAlertStyle` (`BrixTheme.alert`, `BrixAlert.show(style:)`): width, corners, padding, icon on / off and sizes, text alignment, title / message styles, buttons stacked or side by side, gap.
- `alertBuilder` (`BrixTheme.alertBuilder`, `BrixAlert.show(builder:)`): an own alert card from `BrixAlertData`; brix keeps the dimmed screen, animation, returned value and replacing.
- `BrixToastStyle` (`BrixTheme.toast`): top or bottom (`BrixToastPosition`), duration, width, margin, corners, padding, icon size, text styles. `BrixToast.success(duration:)` is now optional and falls back to the theme.
- `toastBuilder` (`BrixTheme.toastBuilder`): an own toast card from `BrixToastData` with `dismiss`; brix keeps the timer, placing and swiping.
- `BrixAlertStyle.alignment` / `margin` / `transition` (`BrixAlertTransition`: scale, fade, slideUp, slideDown) / `transitionDuration`: put alerts anywhere, centre, a bottom sheet, a top banner.
- Screenshots are rendered at 2x, so thin borders stay sharp.
- Nothing fixed any more: `BrixLoaderStyle` / `loaderBuilder` (loading buttons use them too), `BrixButtonStyle.pressDuration` / `fadeDuration`, `BrixTextFieldStyle.requiredMarker` / `requiredMarkerStyle` / `errorStyle` / `errorMaxLines`, `BrixAlertStyle.scrimColor`, `BrixToastPosition.center`, `BrixToastStyle.animationDuration` / `reverseDuration`.
- Example app (`example/`): every widget on one screen, light / dark and three brands switched live; end-to-end tests; checked in CI.
