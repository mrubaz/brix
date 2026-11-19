Buttons, text fields, a select, cards, dialogs, sheets, toasts and a loader that look like your app. They take every colour, font and size from one theme, so switching to dark mode changes nothing in your screens.

[![pub](https://img.shields.io/pub/v/brix_ui)](https://pub.dev/packages/brix_ui)
[![CI](https://github.com/mrubaz/brix/actions/workflows/ci.yml/badge.svg)](https://github.com/mrubaz/brix/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/mrubaz/brix/blob/main/LICENSE)

![One kit in three brands](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/your_brand.png)

Starting a new app? `brix create my_app` from [brix_cli](https://pub.dev/packages/brix_cli) sets brix_ui up with a theme for you.

## Contents

- [Features](#features)
- [Install](#install)
- [Start](#start)
- [Buttons](#buttons)
- [Text fields](#text-fields)
- [Dialogs](#dialogs)
- [Dialog, sheet or toast?](#dialog-sheet-or-toast)
- [Sheets](#sheets)
- [Select](#select)
- [Search](#search)
- [Cards](#cards)
- [Toasts](#toasts)
- [Text styles](#text-styles)
- [Responsive](#responsive)
- [Make it yours](#make-it-yours)
- [With brix auth](#with-brix-auth)
- [Example](#example)
- [Screenshots](#screenshots)
- [Not included yet](#not-included-yet)
- [The brix family](#the-brix-family)

## Features

- Your look. Colours, font, corners, heights, texts and icons all come from `BrixTheme`. Nothing is fixed in the widgets.
- Light and dark from the start. Theme changes animate.
- The small logic is done. A loading button ignores extra taps, a dialog opens from a controller and tells you which button was tapped, a toast hides by itself.
- Dialogs you can read on any screen. They are a solid card on a dimmed background. If you like frosted glass, it is one setting.
- Any language. Every text the kit shows on its own can be replaced.
- Accessible. Touch targets are at least 44 points, labels are read with their fields and toasts are announced to screen readers.
- Light on dependencies. Only Flutter and [brix](https://pub.dev/packages/brix), no state library and no font or sizing package.

## Install

```bash
flutter pub add brix_ui
```

## Start

```dart
import 'package:brix_ui/brix_ui.dart';

const brand = Color(0xFF1E7A4C);

MaterialApp(
  navigatorKey: BrixUi.navigatorKey ??= GlobalKey(), // dialogs from anywhere
  theme: BrixTheme.light(
    colors: const BrixColors.light(primary: brand),
    typography: BrixTypography(fontFamily: 'Inter'),
  ).toThemeData(),
  darkTheme: BrixTheme.dark(
    colors: const BrixColors.dark(primary: brand),
  ).toThemeData(),
  themeMode: ThemeMode.system,
);
```

- Using GetX? `BrixUi.navigatorKey = Get.key;`
- Already have a `ThemeData`? Add the tokens to it: `ThemeData(extensions: [BrixTheme.light()])`.
- No theme at all? The widgets still work, with iOS-like defaults for the app's brightness.

![Light and dark](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/light_dark.png)

## Buttons

```dart
BrixButton(label: 'Log in', isLoading: loading, onPressed: login)
BrixButton(label: 'Continue', gradient: true, onPressed: next)
BrixButton.outlined(label: 'Back', onPressed: back)
BrixButton.destructive(label: 'Delete account', icon: Icons.delete_outline, onPressed: delete)
```

- While loading it keeps its size and ignores taps, so a request is never sent twice.
- `onPressed: null` disables it.
- A light haptic and a small press scale (turn haptics off with `haptics: false`).
- Full width by default (forms); `expand: false` fits the label.

![Buttons](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/buttons.png)

## Text fields

```dart
AutofillGroup(
  child: Column(children: [
    BrixTextField(
      controller: email,
      label: 'Email',
      isRequired: true,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
    ),
    BrixTextField(
      controller: password,
      label: 'Password',
      isRequired: true,
      isPassword: true,
      autofillHints: const [AutofillHints.password],
      onSubmitted: (_) => login(),
    ),
  ]),
)
```

- **Required:** a `*` on the label; inside a `Form`, an empty check when you give no `validator`.
- **Password:** show / hide button, no autocorrect, the value is never trimmed.
- **Keyboard:** Next moves to the next field; Done or a tap outside closes the keyboard.
- **Errors:** your `validator`, or `errorText` from outside (e.g. the backend's field error).
- **Read-only / disabled** have their own look (a read-only field can open a picker on tap).

![Text fields](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/text_fields.png)

## Dialogs

```dart
BrixDialog.warning('Enter your email address.');
BrixDialog.error('No internet connection.');

final delete = await BrixDialog.show<bool>(
  title: 'Delete this photo?',
  message: 'This cannot be undone.',
  icon: const BrixIcon(Icons.delete_outline),
  buttons: const [
    BrixDialogButton(label: 'Cancel', value: false),
    BrixDialogButton.destructive(label: 'Delete', value: true),
  ],
);
```

- `warning` / `error` open from anywhere (a controller too), stay on top while the screen underneath changes, and a new one replaces the open one.
- `show` returns the tapped button's value. Two buttons sit side by side, more are stacked.
- Long messages scroll; the screen below cannot be tapped.

![Dialogs](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/dialogs.png)

## Dialog, sheet or toast?

- A dialog sits in the middle of the screen and asks one clear question: "Delete this photo?". The screen behind is dimmed until a button is tapped.
- A sheet slides up from the bottom and holds more: a list of choices, a short form, a few actions. People drag it down to close it.
- A toast is a short note that something worked. It hides by itself and never blocks the screen.

## Sheets

```dart
final folder = await BrixSheet.show<String>(
  title: 'Move to',
  builder: (context) => Column(children: [
    ListTile(
      title: const Text('Archive'),
      onTap: () => BrixSheet.close(context, 'archive'),
    ),
    ListTile(
      title: const Text('Trash'),
      onTap: () => BrixSheet.close(context, 'trash'),
    ),
  ]),
);
```

- It opens as tall as its content, or at half or full height with `height: BrixSheetHeight.half`.
- Drag it down or tap outside to close it; `dismissible: false` keeps it open until your code closes it.
- `show` returns the value you close it with, or `null` when it was dragged away.

![Sheets](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/sheets.png)

## Select

A dropdown that matches your text fields. Up to six options open in a menu under the field, more open in a sheet with a list.

```dart
BrixSelect<String>(
  label: 'Country',
  isRequired: true,
  value: country,
  options: const [
    BrixOption(value: 'pk', label: 'Pakistan'),
    BrixOption(value: 'gb', label: 'United Kingdom'),
  ],
  onChanged: (value) => setState(() => country = value),
)
```

- It is typed: `BrixSelect<Country>` gives you a `Country` back.
- Inside a `Form`, a required select checks that something is chosen.
- `mode: BrixSelectMode.menu` or `.sheet` picks the way it opens yourself.

![Select](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/select.png)

## Search

Two ways to search, for short and long lists.

**A select with a search box.** `searchable: true` adds a search box on top of the options; the list narrows while typing. It always opens in a sheet.

```dart
BrixSelect<String>(label: 'Country', searchable: true, options: countries, onChanged: pick)
```

**`BrixSearchField`: type and pick.** A text field with suggestions under it. The options can be a list you have (filtered on the device) or come from your backend while typing:

```dart
BrixSearchField<City>(
  label: 'City',
  search: (text) => repository.searchCities(text), // or options: [...]
  onSelected: (city) => setState(() => this.city = city),
  onFreeText: (text) => setState(() => cityName = text),
)
```

- The backend is asked only after typing stops (300 ms, `debounce`), a loader shows meanwhile, an older answer never replaces a newer one, and an error shows a short message instead of crashing.
- With `onFreeText`, text that matches no option can be used too: a **Use "..."** row appears, or the user presses done. What your app shows next (extra fields, a note) is up to you; brix shows nothing more.
- `initialValue` fills the field with a saved value (or pass your own `controller`). Required check, form validation, `minLength` and the looks of the field (`fieldStyle`) and the list (`style`) work like the other widgets.
- Works offline too when `search` reads through `BrixOfflineCache` from [brix_storage](https://pub.dev/packages/brix_storage): the backend when online, the saved copy when not.

![Search](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/search.png)

## Cards

A surface for your own content: the theme's colour, corners, a soft shadow and padding. What goes inside is yours.

```dart
BrixCard(child: Text('3 new orders today'))

BrixCard(
  accentColor: context.brix.colors.success, // a strip on the leading edge, e.g. a status
  onTap: () => open(order),                 // shrinks a little while held, light tap feel
  child: OrderSummary(order),
)
```

- Like Flutter's `Card` it is as wide as its content. In a `ListView` or a `Column(crossAxisAlignment: CrossAxisAlignment.stretch)` it takes the full width.
- A tappable card is a button for screen readers; `semanticLabel` gives it one short label.
- Four levels to change it: the theme colours and `shape.radius`, every card with `BrixTheme(card: BrixCardStyle(...))`, one card with `style:`, or a completely own card with `cardBuilder` (brix keeps the tap and the pressed state).

![Cards](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/card.png)

## Toasts

```dart
BrixToast.success('Profile saved');
BrixToast.success('We sent a code to ada@brix.dev', title: 'Check your email');
```

Slides in at the top, hides after 3 seconds (or on tap / swipe up), never blocks the screen, and screen readers announce it.

![Toasts](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/toast.png)

## Text styles

Every style your screens need, iOS sizes, from one theme. Colours come from the theme too, so they work in light and dark. Text grows with the user's text size setting, never with the screen width.

```dart
Text('Welcome', style: context.brix.typography.largeTitle)
Text('3 new orders', style: context.brix.typography.headline)
```

| Style | Size | Use |
|---|---|---|
| `largeTitle` | 34 | the big title of a screen |
| `title1`, `title2`, `title3` | 28, 22, 20 | headings (`title3` follows `title`) |
| `headline` | 17, semibold | the main line of a row or card |
| `body`, `callout` | 16 | running text, notes |
| `subheadline` | 15 | the second line of a row |
| `footnote` | 13 | small print |
| `caption`, `caption2` | 12, 11 | hints, time stamps |
| `label`, `button` | 14, 16 | field labels and button text |

Change the font of all of them with `BrixTypography(fontFamily: 'Inter')`, or any one style: `BrixTypography(headline: GoogleFonts.poppins(fontSize: 18))`.

![Text styles](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/text_scale.png)

## Responsive

brix follows Flutter's adaptive layout advice: decide the layout from the room the window has, keep content readable, and never scale fonts with the screen.

```dart
final window = context.brixWindow;   // compact, medium, expanded, large, extraLarge
if (window.isCompact) return const OnePane();
return const TwoPanes();
```

- **Window size classes** are the Material 3 ones: compact under 600, medium from 600, expanded from 840, large from 1200, extra large from 1600. Change them with `BrixBreakpoints(medium: 700)` in the theme.
- **`BrixContent`** keeps a form or a list readable: centred, at most 640 wide, with the page padding of the window (16 on phones, 24 on medium, 32 on wider windows).

```dart
Scaffold(body: BrixContent(child: LoginForm()))
```

- **Spacing steps** keep screens in line: `context.brix.spacing.s` (8), `m` (12), `l` (16), `xl` (24) and more, changed in one place with `BrixSpacing(...)`.

## Make it yours

Everything has a default. Change only what you need.

| What | How |
|---|---|
| Colours | `BrixColors.light(primary: ..., background: ..., danger: ...)` and `BrixColors.dark(...)` |
| Font and text sizes | `BrixTypography(fontFamily: 'Inter')`, or whole styles: `BrixTypography(title: GoogleFonts.poppins(fontSize: 22))` |
| Corners and sizes | `BrixShape(radius: 26, buttonHeight: 54, fieldHeight: 54, borderWidth: 1.5)` |
| Texts (any language) | `BrixUiTexts(ok: 'ٹھیک ہے', errorTitle: 'خرابی', requiredField: '...')` |
| Icons (any set, SVG too) | `BrixUiIcons(success: BrixIcon(CupertinoIcons.check_mark_circled), error: BrixIcon.custom(svg))` |
| Frosted glass dialogs and toasts | `BrixTheme.light(glass: true)` |
| Every button's look | `BrixButtonStyle(radius: 40, height: 56, upperCase: true, gradient: true, pressedScale: 1, ...)` |
| A completely own button | `buttonBuilder: (context, button) => MyButton(...)`, brix keeps the logic |
| Every field's look | `BrixTextFieldStyle(border: BrixFieldBorder.underline, labelInside: true, radius: 24, fillColor: ...)` |
| A completely own field | `textFieldBuilder: (context, field) => MyField(...)`, brix keeps the logic |
| Every dialog's place and look | `BrixDialogStyle(alignment: Alignment.bottomCenter, transition: BrixDialogTransition.slideUp, maxWidth: 300, showIcon: false, buttonsVertical: true, ...)` |
| A completely own dialog card | `dialogBuilder: (context, dialog) => MyCard(...)`, brix keeps the dimmed screen and the returned value |
| Toast place, time and look | `BrixToastStyle(position: BrixToastPosition.bottom, duration: Duration(seconds: 2), animationDuration: ..., ...)`, top, centre or bottom |
| A completely own toast | `toastBuilder: (context, toast) => MyToast(...)`, brix keeps the timer and swiping |
| Sheets | `BrixSheetStyle(radius: 16, showGrabber: false, backgroundColor: ...)`, or `sheetBuilder: (context, sheet) => MySheet(...)` |
| Select menus and sheets | `BrixSelectStyle(menuRadius: 14, selectedColor: ...)`, or `selectBuilder: (context, select) => MyPicker(...)`; the field follows your text field style |
| Cards | `BrixCardStyle(radius: 20, padding: ..., shadow: [], borderWidth: 0, accentWidth: 6, pressedScale: 1, haptics: false)`, or `cardBuilder: (context, card) => MyCard(...)`, brix keeps the tap and the pressed state |
| Spinner | `BrixLoaderStyle(radius: 14, color: ...)`, or `loaderBuilder: (context, loader) => MySpinner(...)`, loading buttons use it too |
| Button animation speed | `BrixButtonStyle(pressDuration: ..., fadeDuration: ...)` |
| Required marker and errors | `BrixTextFieldStyle(requiredMarker: ' (required)', requiredMarkerStyle: ..., errorStyle: ..., errorMaxLines: 2)` |
| Dimmed screen behind dialogs | `BrixDialogStyle(scrimColor: ...)`, transparent to keep the screen as it is |

```dart
BrixTheme.light(
  colors: const BrixColors.light(primary: Color(0xFF1E7A4C)),
  shape: const BrixShape(radius: 26),
  texts: const BrixUiTexts(ok: 'ٹھیک ہے'),
  icons: BrixUiIcons(error: BrixIcon.custom(SvgPicture.asset('assets/error.svg'))),
)
```

### Buttons your way

Three levels: use the one you need:

```dart
// 1. Every button in the app.
BrixTheme.light(
  button: const BrixButtonStyle(radius: 40, height: 56, upperCase: true, gradient: true),
)

// 2. One button.
BrixButton(label: 'Skip', style: const BrixButtonStyle(height: 40), onPressed: skip)

// 3. Your own widget. brix still blocks double taps, plays the haptic and
//    disables it while loading.
BrixTheme.light(
  buttonBuilder: (context, button) => MyButton(
    label: button.label,
    danger: button.variant == BrixButtonVariant.destructive,
    busy: button.isLoading,
    onTap: button.onPressed, // null while loading or disabled
  ),
)
```

Dialogs use your button too, so the whole app matches.

![Default, theme style and own builder](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/buttons_custom.png)

### Text fields your way

The same three levels:

```dart
// 1. Every field: outline (default), underline or none; label above or inside.
BrixTheme.light(
  textField: const BrixTextFieldStyle(border: BrixFieldBorder.underline, labelInside: true),
)

// 2. One field.
BrixTextField(label: 'Notes', maxLines: 4, style: const BrixTextFieldStyle(radius: 20))

// 3. Your own widget. Pass brix's values to your TextFormField and the
//    required check, password show / hide and Next / Done keep working.
BrixTheme.light(
  textFieldBuilder: (context, field) => TextFormField(
    controller: field.controller,
    focusNode: field.focusNode,
    validator: field.validator,
    obscureText: field.obscureText,
    textInputAction: field.textInputAction,
    onEditingComplete: field.onEditingComplete,
    onTapOutside: field.onTapOutside,
    decoration: MyDecoration(label: field.label, onEye: field.toggleObscured),
  ),
)
```

![Default, theme style and own builder](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/text_fields_custom.png)

### Dialogs and toasts your way

```dart
BrixTheme.light(
  // Anywhere on the screen: centre (default), a bottom sheet, a top banner.
  dialog: const BrixDialogStyle(
    alignment: Alignment.bottomCenter,
    transition: BrixDialogTransition.slideUp, // scale, fade, slideUp, slideDown
    margin: EdgeInsets.all(12),
    showIcon: false,
    textAlign: TextAlign.start,
    buttonsVertical: true,
  ),
  toast: const BrixToastStyle(position: BrixToastPosition.bottom),

  // Your own cards. brix still dims the screen, animates, returns the
  // tapped value, runs the toast timer and handles swipes.
  dialogBuilder: (context, dialog) => MyDialogCard(
    title: dialog.title,
    message: dialog.message,
    actions: [
      for (final button in dialog.buttons)
        MyAction(button.label, onTap: () => dialog.onPressed(button.value)),
    ],
  ),
  toastBuilder: (context, toast) => MySnack(toast.message, onUndo: toast.dismiss),
)
```

One dialog only: `BrixDialog.show(style: ..., builder: ...)`.

![Default, theme style, own dialog card and own bottom toast](https://raw.githubusercontent.com/mrubaz/brix/main/packages/brix_ui/doc/screenshots/dialogs_toasts_custom.png)

Read the tokens in your own widgets too, so they match:

```dart
final brix = context.brix;
Text('Hello', style: brix.typography.body.copyWith(color: brix.colors.text));
```

## With brix auth

`BrixUiFeedback` is a ready [brix](https://pub.dev/packages/brix) `AuthFeedback`: failures and warnings as dialogs, success messages as a toast. No adapter to write:

```dart
LoginFlow(
  provider: MyAuth(),
  store: store,
  navigator: MyNavigator(),
  feedback: const BrixUiFeedback(),
)
```

When the backend sends no message (e.g. no connection), brix's default text is shown, so a dialog is never empty.

## Example

[`example/`](https://github.com/mrubaz/brix/tree/main/packages/brix_ui/example) shows every widget on one screen. Switch light and dark and three brands live; see [`example/lib/brands.dart`](https://github.com/mrubaz/brix/tree/main/packages/brix_ui/example/lib/brands.dart) for how each brand is set up.

## Screenshots

The images on this page are rendered from the real widgets by `tool/screenshots_test.dart`:

```bash
flutter test tool/screenshots_test.dart --update-goldens            # widgets
```

## Not included yet

- Charts, date pickers and data tables: use your favourite package inside the brix theme.

## The brix family

| Package | What it does |
|---|---|
| [brix_cli](https://pub.dev/packages/brix_cli) | Start here: `brix create` makes the whole app on Bloc, Riverpod or GetX |
| [brix_ui](https://pub.dev/packages/brix_ui) | Widgets and theme, light and dark |
| [brix_bloc](https://pub.dev/packages/brix_bloc) | Cubits for every account screen |
| [brix_riverpod](https://pub.dev/packages/brix_riverpod) | Riverpod notifiers for every account screen |
| [brix_getx](https://pub.dev/packages/brix_getx) | GetX controllers for every account screen |
| [brix_network](https://pub.dev/packages/brix_network) | API calls that return a result, never throw |
| [brix_storage](https://pub.dev/packages/brix_storage) | Tokens, settings and offline copies, kept safe |
| [brix](https://pub.dev/packages/brix) | The core: login, signup and account flows in pure Dart |

## Help

Questions, bugs and ideas: [GitHub issues](https://github.com/mrubaz/brix/issues).

## License

MIT
