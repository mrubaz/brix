// Renders the README / pub.dev screenshots from the real widgets.
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (only `test/` runs there): font rendering
// differs a little between machines, so these images are made on demand.

import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/screenshot_kit/iphone.dart';

const _out = '../doc/screenshots';

Future<void> _loadFonts() => loadAppleFonts();

BrixTypography _type() => BrixTypography(fontFamily: sfPro);

final _light = BrixTheme.light(typography: _type());
final _dark = BrixTheme.dark(typography: _type());

/// A phone-like screen in [theme] with a caption under it.
Widget _screen(
  BrixTheme theme,
  String caption,
  Widget child, {
  double height = 520,
  bool fullBleed = false,
}) {
  final dark = theme.brightness == Brightness.dark;
  return Captioned(
    caption: caption,
    child: IPhone(
      dark: dark,
      child: Theme(
        data: iosTheme(theme.toThemeData()),
        child: Builder(
          builder: (context) => Material(
            color: context.brix.colors.background,
            child: Padding(
              padding: EdgeInsets.only(
                top: fullBleed || child is _FullBleed ? 0 : 40,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The sign-in form used on several screenshots.
Widget _loginForm({String title = 'Welcome back'}) {
  return Builder(
    builder: (context) {
      final brix = context.brix;
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: brix.typography.title.copyWith(
                color: brix.colors.text,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue',
              style: brix.typography.body.copyWith(
                color: brix.colors.mutedText,
              ),
            ),
            const SizedBox(height: 28),
            BrixTextField(
              controller: TextEditingController(text: 'ada@brix.dev'),
              label: 'Email',
              isRequired: true,
              prefixIcon: const Icon(Icons.mail_outline),
            ),
            const SizedBox(height: 16),
            BrixTextField(
              controller: TextEditingController(text: 'secret123'),
              label: 'Password',
              isRequired: true,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            const SizedBox(height: 28),
            BrixButton(label: 'Log in', onPressed: () {}),
            const SizedBox(height: 12),
            BrixButton.outlined(label: 'Create account', onPressed: () {}),
          ],
        ),
      );
    },
  );
}

/// Busy, colourful screen content, to show alerts read on any background.
Widget _colourfulBackground() {
  const colors = [
    Color(0xFFFF9F43),
    Color(0xFF54A0FF),
    Color(0xFF1DD1A1),
    Color(0xFFFF6B6B),
    Color(0xFF5F27CD),
    Color(0xFFFECA57),
  ];
  return GridView.count(
    crossAxisCount: 2,
    padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (final color in colors)
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
    ],
  );
}

/// An alert as it shows in the app: over the screen, behind the scrim.
Widget _alertOver(Widget alert) {
  return _FullBleed(
    child: Builder(
      builder: (context) => Stack(
        fit: StackFit.expand,
        children: [
          _colourfulBackground(),
          ColoredBox(color: context.brix.colors.scrim),
          alert,
        ],
      ),
    ),
  );
}

/// A screen that also fills the status bar area (alerts dim all of it).
class _FullBleed extends StatelessWidget {
  const _FullBleed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Pumps [screens] side by side on a [width] × [height] page, painted at
/// 2x so thin lines and curves stay sharp, and saves `$_out/[name].png`.
Future<void> _shoot(
  WidgetTester tester,
  String name,
  List<Widget> screens, {
  double height = 640,
}) => shootRow(tester, '$_out/$name.png', screens);

void main() {
  setUpAll(_loadFonts);

  testWidgets('light and dark', (tester) async {
    await _shoot(tester, 'light_dark', [
      _screen(_light, 'Light', _loginForm()),
      _screen(_dark, 'Dark, same code', _loginForm()),
    ]);
  });

  testWidgets('buttons', (tester) async {
    Widget buttons() => Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          BrixButton(label: 'Filled', onPressed: () {}),
          const SizedBox(height: 12),
          BrixButton(label: 'Gradient', gradient: true, onPressed: () {}),
          const SizedBox(height: 12),
          BrixButton.outlined(label: 'Outlined', onPressed: () {}),
          const SizedBox(height: 12),
          BrixButton.destructive(
            label: 'Delete account',
            icon: Icons.delete_outline,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          BrixButton(label: 'Loading', isLoading: true, onPressed: () {}),
          const SizedBox(height: 12),
          const BrixButton(label: 'Disabled', onPressed: null),
        ],
      ),
    );
    await _shoot(tester, 'buttons', [
      _screen(_light, 'Buttons', buttons()),
      _screen(_dark, 'Buttons, dark', buttons()),
    ]);
  });

  testWidgets('text fields', (tester) async {
    Widget fields() => Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          BrixTextField(
            controller: TextEditingController(text: 'Ada Lovelace'),
            label: 'Name',
          ),
          const SizedBox(height: 14),
          const BrixTextField(
            label: 'Email',
            isRequired: true,
            hint: 'you@example.com',
            errorText: 'This field is required.',
          ),
          const SizedBox(height: 14),
          BrixTextField(
            controller: TextEditingController(text: 'secret123'),
            label: 'Password',
            isPassword: true,
          ),
          const SizedBox(height: 14),
          BrixTextField(
            controller: TextEditingController(text: 'United Kingdom'),
            label: 'Country',
            readOnly: true,
            suffixIcon: const Icon(Icons.expand_more),
          ),
        ],
      ),
    );
    await _shoot(tester, 'text_fields', [
      _screen(_light, 'Text fields', fields()),
      _screen(_dark, 'Text fields, dark', fields()),
    ]);
  });

  testWidgets('alerts', (tester) async {
    Widget alert({
      required String title,
      required String message,
      required BrixIcon icon,
      required Color Function(BrixColors) accent,
      required List<BrixAlertButton<Object?>> buttons,
    }) => Builder(
      builder: (context) => BrixAlert(
        title: title,
        message: message,
        icon: icon,
        accent: accent(context.brix.colors),
        buttons: buttons,
        onPressed: (_) {},
      ),
    );

    await _shoot(tester, 'alerts', [
      _screen(
        _light,
        'BrixAlert.warning',
        _alertOver(
          alert(
            title: 'Please check',
            message: 'Enter your email address.',
            icon: _light.icons.warning,
            accent: (c) => c.warning,
            buttons: const [BrixAlertButton.primary(label: 'OK')],
          ),
        ),
      ),
      _screen(
        _dark,
        'BrixAlert.error',
        _alertOver(
          alert(
            title: 'Something went wrong',
            message:
                'No internet connection. Check your connection and try again.',
            icon: _dark.icons.error,
            accent: (c) => c.danger,
            buttons: const [BrixAlertButton.primary(label: 'OK')],
          ),
        ),
      ),
      _screen(
        _light,
        'BrixAlert.show, returns a value',
        _alertOver(
          alert(
            title: 'Delete this photo?',
            message: 'This cannot be undone.',
            icon: const BrixIcon(Icons.delete_outline),
            accent: (c) => c.danger,
            buttons: const [
              BrixAlertButton(label: 'Cancel', value: false),
              BrixAlertButton.destructive(label: 'Delete', value: true),
            ],
          ),
        ),
      ),
    ]);
  });

  testWidgets('toast', (tester) async {
    Widget profileForm() => Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
        child: Column(
          children: [
            BrixTextField(
              controller: TextEditingController(text: 'Ada Lovelace'),
              label: 'Name',
            ),
            const SizedBox(height: 16),
            BrixTextField(
              controller: TextEditingController(text: '+44 20 7946 0000'),
              label: 'Phone',
            ),
            const SizedBox(height: 28),
            BrixButton(label: 'Save', onPressed: () {}),
          ],
        ),
      ),
    );
    Widget toastOver(String message, {String? title}) => Stack(
      children: [
        Positioned.fill(child: profileForm()),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: BrixToast(message: message, title: title),
        ),
      ],
    );
    await _shoot(tester, 'toast', [
      _screen(_light, 'BrixToast.success', toastOver('Profile saved')),
      _screen(
        _dark,
        'With a title, dark',
        toastOver('We sent a code to ada@brix.dev', title: 'Check your email'),
      ),
    ]);
  });

  testWidgets('your brand', (tester) async {
    final forest = BrixTheme.light(
      colors: const BrixColors.light(
        primary: Color(0xFF1E7A4C),
        secondary: Color(0xFF52B788),
        background: Color(0xFFF1F7F2),
        border: Color(0xFFB7D3C0),
      ),
      typography: _type(),
      shape: const BrixShape(radius: 26, buttonHeight: 54, fieldHeight: 54),
    );
    final sunset = BrixTheme.dark(
      colors: const BrixColors.dark(
        primary: Color(0xFFFF7A59),
        secondary: Color(0xFFFFB86B),
        background: Color(0xFF1A1325),
        surface: Color(0xFF2A2038),
        border: Color(0xFF4A3A60),
      ),
      typography: _type(),
      shape: const BrixShape(radius: 6, borderWidth: 1.5),
    );
    await _shoot(tester, 'your_brand', [
      _screen(_light, 'Default', _loginForm()),
      _screen(forest, 'Your colours, round shape', _loginForm()),
      _screen(sunset, 'Dark brand, sharp corners', _loginForm()),
    ]);
  });

  testWidgets('custom buttons', (tester) async {
    Widget buttons() => Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          BrixButton(label: 'Continue', onPressed: () {}),
          const SizedBox(height: 14),
          BrixButton.outlined(label: 'Back', onPressed: () {}),
          const SizedBox(height: 14),
          BrixButton.destructive(
            label: 'Delete',
            icon: Icons.delete_outline,
            onPressed: () {},
          ),
          const SizedBox(height: 14),
          BrixButton(label: 'Saving', isLoading: true, onPressed: () {}),
        ],
      ),
    );

    final pill = BrixTheme.light(
      typography: _type(),
      button: const BrixButtonStyle(
        radius: 40,
        height: 56,
        upperCase: true,
        gradient: true,
        textStyle: TextStyle(letterSpacing: 1.2),
      ),
    );

    // An app's own button: brix only passes the data and keeps the logic.
    Widget bold(BuildContext context, BrixButtonData button) {
      final fill = switch (button.variant) {
        BrixButtonVariant.outlined => Colors.white,
        BrixButtonVariant.destructive => const Color(0xFFFF6B6B),
        _ => const Color(0xFFFFD43B),
      };
      return GestureDetector(
        onTap: button.onPressed,
        child: Container(
          height: 52,
          width: button.expand ? double.infinity : null,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(width: 2.5),
            boxShadow: const [BoxShadow(offset: Offset(4, 4), blurRadius: 0)],
          ),
          child: button.isLoading
              ? const BrixLoader(color: Colors.black)
              : Text(
                  button.label,
                  style: const TextStyle(
                    fontFamily: sfPro,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
        ),
      );
    }

    final own = BrixTheme.light(
      typography: _type(),
      colors: const BrixColors.light(background: Color(0xFFFFF8E7)),
      buttonBuilder: bold,
    );

    await _shoot(tester, 'buttons_custom', [
      _screen(_light, 'Default', buttons(), height: 360),
      _screen(pill, 'BrixButtonStyle in the theme', buttons(), height: 360),
      _screen(own, 'Your own button (buttonBuilder)', buttons(), height: 360),
    ], height: 480);
  });

  testWidgets('custom text fields', (tester) async {
    Widget fields() => Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          BrixTextField(
            controller: TextEditingController(text: 'Ada Lovelace'),
            label: 'Name',
          ),
          const SizedBox(height: 18),
          const BrixTextField(
            label: 'Email',
            isRequired: true,
            errorText: 'Enter a valid email.',
          ),
          const SizedBox(height: 18),
          BrixTextField(
            controller: TextEditingController(text: 'secret123'),
            label: 'Password',
            isPassword: true,
          ),
        ],
      ),
    );

    final underline = BrixTheme.light(
      typography: _type(),
      textField: const BrixTextFieldStyle(
        border: BrixFieldBorder.underline,
        labelInside: true,
        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      ),
    );

    // An app's own field: brix passes controller, validator, password
    // state and keyboard actions; the app only draws.
    Widget soft(BuildContext context, BrixTextFieldData field) {
      const ink = Color(0xFF3D2C8D);
      final error = field.errorText;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.label != null)
            Padding(
              padding: const EdgeInsets.only(left: 18, bottom: 6),
              child: Text(
                field.label!.toUpperCase(),
                style: const TextStyle(
                  fontFamily: sfPro,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ),
          TextFormField(
            controller: field.controller,
            focusNode: field.focusNode,
            obscureText: field.obscureText,
            validator: field.validator,
            onTapOutside: field.onTapOutside,
            style: const TextStyle(fontFamily: sfPro, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFEDE9FF),
              errorText: error,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: field.toggleObscured == null
                  ? null
                  : IconButton(
                      onPressed: field.toggleObscured,
                      icon: Icon(
                        field.obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: ink,
                      ),
                    ),
            ),
          ),
        ],
      );
    }

    final own = BrixTheme.light(
      typography: _type(),
      colors: const BrixColors.light(background: Color(0xFFF8F6FF)),
      textFieldBuilder: soft,
    );

    await _shoot(tester, 'text_fields_custom', [
      _screen(_light, 'Default', fields(), height: 420),
      _screen(underline, 'Underline, label inside', fields(), height: 420),
      _screen(own, 'Your own field (textFieldBuilder)', fields(), height: 420),
    ], height: 540);
  });

  testWidgets('custom alerts and toasts', (tester) async {
    const buttons = [
      BrixAlertButton<Object?>(label: 'Cancel', value: false),
      BrixAlertButton<Object?>.destructive(label: 'Delete', value: true),
    ];
    Widget alertIn(BrixTheme theme) => Builder(
      builder: (context) => BrixAlert(
        title: 'Delete this photo?',
        message: 'This cannot be undone.',
        icon: const BrixIcon(Icons.delete_outline),
        accent: context.brix.colors.danger,
        buttons: buttons,
        onPressed: (_) {},
      ),
    );

    final styled = BrixTheme.light(
      typography: _type(),
      alert: const BrixAlertStyle(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
        transition: BrixAlertTransition.slideUp,
        maxWidth: double.infinity,
        showIcon: false,
        textAlign: TextAlign.start,
        buttonsVertical: true,
        radius: 28,
        titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      button: const BrixButtonStyle(radius: 40),
    );

    // An app's own alert card: brix keeps the dimmed screen, animation and
    // the returned value.
    Widget sheet(BuildContext context, BrixAlertData alert) {
      return Container(
        width: 290,
        decoration: BoxDecoration(
          color: const Color(0xFF14213D),
          borderRadius: BorderRadius.circular(8),
          border: Border(top: BorderSide(color: alert.accent, width: 5)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.title,
              style: const TextStyle(
                fontFamily: sfPro,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (alert.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  alert.message!,
                  style: const TextStyle(
                    fontFamily: sfPro,
                    fontSize: 14,
                    color: Color(0xFFB8C1D9),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final button in alert.buttons)
                  TextButton(
                    onPressed: () => alert.onPressed(button.value),
                    child: Text(
                      button.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: sfPro,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: button.isDestructive
                            ? alert.accent
                            : const Color(0xFFB8C1D9),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    final own = BrixTheme.light(
      typography: _type(),
      colors: const BrixColors.light(danger: Color(0xFFFF6B6B)),
      alertBuilder: sheet,
    );

    // An app's own toast at the bottom: a dark pill with an Undo action.
    Widget pill(BuildContext context, BrixToastData toast) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            toast.icon.build(color: toast.accent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                toast.message,
                style: const TextStyle(
                  fontFamily: sfPro,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: toast.dismiss,
              child: const Text(
                'Undo',
                style: TextStyle(
                  fontFamily: sfPro,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFD43B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final toastTheme = BrixTheme.light(
      typography: _type(),
      toast: const BrixToastStyle(position: BrixToastPosition.bottom),
      toastBuilder: pill,
    );

    await _shoot(tester, 'alerts_toasts_custom', [
      _screen(_light, 'Default', _alertOver(alertIn(_light)), height: 480),
      _screen(
        styled,
        'BrixAlertStyle: bottom sheet',
        _alertOver(alertIn(styled)),
        height: 480,
      ),
      _screen(
        own,
        'Your own card (alertBuilder)',
        _alertOver(alertIn(own)),
        height: 480,
      ),
      _screen(
        toastTheme,
        'Bottom toast (toastBuilder)',
        Stack(
          children: [
            Positioned.fill(
              child: Builder(
                builder: (context) {
                  final brix = context.brix;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 44, 24, 0),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Text(
                        'Inbox',
                        style: brix.typography.title.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: brix.colors.text,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final (from, line) in const [
                        ('Ada', 'Release notes for 1.0'),
                        ('Grace', 'Can you check the build?'),
                        ('Alan', 'Lunch on Friday?'),
                        ('Linus', 'Review is done'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: brix.colors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                child: Text(
                                  from[0],
                                  style: brix.typography.label.copyWith(
                                    color: brix.colors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      from,
                                      style: brix.typography.label.copyWith(
                                        color: brix.colors.text,
                                      ),
                                    ),
                                    Text(
                                      line,
                                      style: brix.typography.body.copyWith(
                                        fontSize: 14,
                                        color: brix.colors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: BrixToast(message: 'Message archived'),
            ),
          ],
        ),
        height: 480,
      ),
    ], height: 600);
  });
}
