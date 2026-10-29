import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../overlay/brix_ui.dart';
import '../theme/brix_icon.dart';
import '../theme/brix_theme.dart';
import '../theme/brix_theme_context.dart';
import 'brix_alert_button.dart';
import 'brix_alert_data.dart';
import 'brix_alert_style.dart';
import 'brix_alert_transition.dart';
import 'brix_button.dart';
import 'brix_panel.dart';

/// A centred alert card on a dimmed screen (`colors.scrim`), so it reads on
/// any background: optional icon, title, message, own content and buttons.
///
/// - [BrixAlert.show] – opens it as a dialog route and returns the tapped
///   button's value (confirm, pick one of a few choices).
/// - [BrixAlert.warning] / [BrixAlert.error] – an OK alert shown above
///   everything (an overlay, not a route): navigating right after it
///   changes the screen underneath and the alert stays on top. A new one
///   replaces the open one.
///
/// ```dart
/// final delete = await BrixAlert.show<bool>(
///   title: 'Delete this photo?',
///   message: 'This cannot be undone.',
///   buttons: const [
///     BrixAlertButton(label: 'Cancel', value: false),
///     BrixAlertButton.destructive(label: 'Delete', value: true),
///   ],
/// );
///
/// BrixAlert.error('No internet connection.');
/// ```
class BrixAlert extends StatelessWidget {
  const BrixAlert({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.accent,
    this.content,
    required this.buttons,
    required this.onPressed,
    this.style,
    this.builder,
  });

  final String title;

  /// Text under the title; new lines show as separate lines.
  final String? message;

  /// Shown in a tinted circle above the title.
  final BrixIcon? icon;

  /// Icon colour; defaults to `colors.primary`.
  final Color? accent;

  /// Own widget under the message (e.g. a text field).
  final Widget? content;

  final List<BrixAlertButton<Object?>> buttons;

  /// Called with the tapped button's value.
  final ValueChanged<Object?> onPressed;

  /// This alert's look, on top of `BrixTheme.alert`.
  final BrixAlertStyle? style;

  /// Draws this alert's card instead of brix (wins over
  /// `BrixTheme.alertBuilder`).
  final BrixAlertBuilder? builder;

  static const _defaultTransitionDuration = Duration(milliseconds: 220);

  static OverlayEntry? _entry;
  static GlobalKey<_OverlayAlertState>? _entryKey;

  /// Opens the alert as a dialog and returns the tapped button's value
  /// (`null` when closed by tapping outside with [dismissible]). Without
  /// [buttons] it shows one OK button.
  static Future<T?> show<T>({
    BuildContext? context,
    required String title,
    String? message,
    BrixIcon? icon,
    Color? accent,
    Widget? content,
    List<BrixAlertButton<T>>? buttons,
    bool dismissible = false,
    BrixAlertStyle? style,
    BrixAlertBuilder? builder,
  }) {
    final host = BrixUi.contextOf(context);
    final brix = BrixTheme.of(host);
    final look = brix.alert.merge(style);
    return showGeneralDialog<T>(
      context: host,
      barrierDismissible: dismissible,
      barrierLabel: MaterialLocalizations.of(host).modalBarrierDismissLabel,
      barrierColor: look.scrimColor ?? brix.colors.scrim,
      transitionDuration: look.transitionDuration ?? _defaultTransitionDuration,
      pageBuilder: (dialogContext, _, _) => BrixAlert(
        title: title,
        message: message,
        icon: icon,
        accent: accent,
        content: content,
        buttons: buttons ?? [BrixAlertButton<T>.primary(label: brix.texts.ok)],
        onPressed: (value) => Navigator.of(dialogContext).pop(value as T?),
        style: style,
        builder: builder,
      ),
      transitionBuilder: (_, animation, _, child) => _AlertTransition(
        animation: animation,
        type: look.transition ?? BrixAlertTransition.scale,
        child: child,
      ),
    );
  }

  /// A problem the user can fix (a field missing, a check failed).
  static void warning(String message, {String? title, BuildContext? context}) {
    _showOverlay(
      context,
      (brix) => BrixAlert(
        title: title ?? brix.texts.warningTitle,
        message: message,
        icon: brix.icons.warning,
        accent: brix.colors.warning,
        buttons: [BrixAlertButton.primary(label: brix.texts.ok)],
        onPressed: (_) => dismiss(),
      ),
    );
  }

  /// Something failed (a request, a save). Several backend messages can be
  /// joined with new lines.
  static void error(String message, {String? title, BuildContext? context}) {
    _showOverlay(
      context,
      (brix) => BrixAlert(
        title: title ?? brix.texts.errorTitle,
        message: message,
        icon: brix.icons.error,
        accent: brix.colors.danger,
        buttons: [BrixAlertButton.primary(label: brix.texts.ok)],
        onPressed: (_) => dismiss(),
      ),
    );
  }

  /// Closes the open [warning] / [error] alert, if any.
  static void dismiss() {
    final state = _entryKey?.currentState;
    if (state != null) {
      state.close();
    } else {
      _removeEntry();
    }
  }

  static void _showOverlay(
    BuildContext? context,
    BrixAlert Function(BrixTheme brix) build,
  ) {
    final overlay = BrixUi.overlayOf(context);
    _removeEntry();
    HapticFeedback.mediumImpact();
    final key = GlobalKey<_OverlayAlertState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _OverlayAlert(
        key: key,
        // Only this alert's entry – a newer one may have replaced it.
        onClosed: () {
          if (_entry == entry) _removeEntry();
        },
        child: build(context.brix),
      ),
    );
    _entry = entry;
    _entryKey = key;
    overlay.insert(entry);
  }

  static void _removeEntry() {
    _entry?.remove();
    _entry = null;
    _entryKey = null;
  }

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final colors = brix.colors;
    final tint = accent ?? colors.primary;
    final style = brix.alert.merge(this.style);
    final builder = this.builder ?? brix.alertBuilder;

    final Widget card;
    if (builder != null) {
      card = builder(
        context,
        BrixAlertData(
          title: title,
          message: message,
          icon: icon,
          accent: tint,
          content: content,
          buttons: buttons,
          onPressed: onPressed,
          style: style,
        ),
      );
    } else {
      final align = style.textAlign ?? TextAlign.center;
      final circle = style.iconCircleSize ?? 56;
      final maxMessageHeight = MediaQuery.sizeOf(context).height * 0.4;
      card = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: style.maxWidth ?? 340),
        child: BrixPanel(
          radius: style.radius,
          padding: style.padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: switch (align) {
              TextAlign.left || TextAlign.start => CrossAxisAlignment.start,
              TextAlign.right || TextAlign.end => CrossAxisAlignment.end,
              _ => CrossAxisAlignment.center,
            },
            children: [
              if (icon != null && (style.showIcon ?? true)) ...[
                Container(
                  width: circle,
                  height: circle,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: icon!.build(color: tint, size: style.iconSize ?? 30),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                textAlign: align,
                style: brix.typography.title
                    .copyWith(color: colors.text)
                    .merge(style.titleStyle),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxMessageHeight),
                  child: SingleChildScrollView(
                    child: Text(
                      message!,
                      textAlign: align,
                      style: brix.typography.body
                          .copyWith(color: colors.mutedText)
                          .merge(style.messageStyle),
                    ),
                  ),
                ),
              ],
              if (content != null) ...[const SizedBox(height: 16), content!],
              const SizedBox(height: 24),
              _buttons(style),
            ],
          ),
        ),
      );
    }

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: SafeArea(
        child: Padding(
          padding: style.margin ?? const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: style.alignment ?? Alignment.center,
            child: Material(type: MaterialType.transparency, child: card),
          ),
        ),
      ),
    );
  }

  /// Two buttons side by side; one or three+ stacked (iOS style).
  Widget _buttons(BrixAlertStyle style) {
    Widget button(BrixAlertButton<Object?> b) {
      void tap() => onPressed(b.value);
      if (b.isDestructive) {
        return BrixButton.destructive(label: b.label, onPressed: tap);
      }
      if (b.isPrimary) return BrixButton(label: b.label, onPressed: tap);
      return BrixButton.outlined(label: b.label, onPressed: tap);
    }

    if (!(style.buttonsVertical ?? buttons.length != 2)) {
      return Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) SizedBox(width: style.buttonGap ?? 12),
            Expanded(child: button(buttons[i])),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) SizedBox(height: style.buttonGap ?? 10),
          button(buttons[i]),
        ],
      ],
    );
  }
}

/// The alert's way in and out ([BrixAlertTransition]).
class _AlertTransition extends StatelessWidget {
  const _AlertTransition({
    required this.animation,
    required this.type,
    required this.child,
  });

  final Animation<double> animation;
  final BrixAlertTransition type;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    Widget slide(double fromY) => SlideTransition(
      position: Tween(
        begin: Offset(0, fromY),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
    return FadeTransition(
      opacity: curved,
      child: switch (type) {
        BrixAlertTransition.fade => child,
        BrixAlertTransition.slideUp => slide(0.3),
        BrixAlertTransition.slideDown => slide(-0.3),
        _ => ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      },
    );
  }
}

/// A warning / error alert in the overlay: scrim that blocks the screen,
/// animated in and out.
class _OverlayAlert extends StatefulWidget {
  const _OverlayAlert({super.key, required this.onClosed, required this.child});

  final VoidCallback onClosed;
  final Widget child;

  @override
  State<_OverlayAlert> createState() => _OverlayAlertState();
}

class _OverlayAlertState extends State<_OverlayAlert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration:
        context.brix.alert.transitionDuration ??
        BrixAlert._defaultTransitionDuration,
  )..forward();

  bool _closing = false;

  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    await _controller.reverse();
    if (mounted) widget.onClosed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _controller,
            // Blocks taps on the screen below; only OK closes the alert.
            child: ModalBarrier(
              color: context.brix.alert.scrimColor ?? context.brix.colors.scrim,
            ),
          ),
        ),
        _AlertTransition(
          animation: _controller,
          type: context.brix.alert.transition ?? BrixAlertTransition.scale,
          child: widget.child,
        ),
      ],
    );
  }
}
