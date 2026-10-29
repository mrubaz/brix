import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../overlay/brix_ui.dart';
import '../theme/brix_icon.dart';
import '../theme/brix_theme_context.dart';
import 'brix_panel.dart';
import 'brix_toast_data.dart';
import 'brix_toast_style.dart';

/// A short message that slides in at the top (or bottom) and hides by
/// itself – for things that went right ("Saved", "Email sent"). Tap or
/// swipe towards the edge to hide it early. A new toast replaces the open
/// one; screen readers announce it.
///
/// Its look comes from `BrixTheme.toast`; draw a completely own card with
/// `BrixTheme.toastBuilder` – brix keeps the timer, placing and swiping.
///
/// ```dart
/// BrixToast.success('Profile saved');
/// ```
class BrixToast extends StatelessWidget {
  const BrixToast({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.accent,
    this.onDismiss,
    this.builder,
  });

  final String message;
  final String? title;

  /// Defaults to the theme's success icon.
  final BrixIcon? icon;

  /// Icon colour; defaults to `colors.success`.
  final Color? accent;

  /// Hides the toast; given to a builder as `dismiss`.
  final VoidCallback? onDismiss;

  /// Draws this toast's card instead of brix (wins over
  /// `BrixTheme.toastBuilder`).
  final BrixToastBuilder? builder;

  static OverlayEntry? _entry;

  /// How long a toast stays when neither the call nor the theme says.
  static const defaultDuration = Duration(seconds: 3);

  /// Shows a success toast for [duration] (default: the theme's toast
  /// duration, else [defaultDuration]).
  static void success(
    String message, {
    String? title,
    Duration? duration,
    BuildContext? context,
  }) {
    final overlay = BrixUi.overlayOf(context);
    dismiss();
    HapticFeedback.lightImpact();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastHost(
        duration: duration,
        onClosed: () {
          if (_entry == entry) dismiss();
        },
        child: (close) =>
            BrixToast(message: message, title: title, onDismiss: close),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  /// Hides the open toast at once, if any.
  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final colors = brix.colors;
    final tint = accent ?? colors.success;
    final style = brix.toast;
    final builder = this.builder ?? brix.toastBuilder;

    final Widget card;
    if (builder != null) {
      card = builder(
        context,
        BrixToastData(
          message: message,
          title: title,
          icon: icon ?? brix.icons.success,
          accent: tint,
          dismiss: onDismiss ?? dismiss,
          style: style,
        ),
      );
    } else {
      card = BrixPanel(
        radius: style.radius,
        padding:
            style.padding ??
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            (icon ?? brix.icons.success).build(
              color: tint,
              size: style.iconSize ?? 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: brix.typography.label
                          .copyWith(
                            color: colors.text,
                            fontWeight: FontWeight.w600,
                          )
                          .merge(style.titleStyle),
                    ),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: brix.typography.body
                        .copyWith(
                          color: title == null ? colors.text : colors.mutedText,
                        )
                        .merge(style.messageStyle),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(liveRegion: true, container: true, child: card);
  }
}

/// Places the toast at the top or bottom, slides it in, hides it after the
/// duration, on tap or on a swipe towards the edge.
class _ToastHost extends StatefulWidget {
  const _ToastHost({
    required this.duration,
    required this.onClosed,
    required this.child,
  });

  /// `null`: the theme's toast duration, else [BrixToast.defaultDuration].
  final Duration? duration;
  final VoidCallback onClosed;
  final Widget Function(VoidCallback close) child;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration:
        context.brix.toast.animationDuration ??
        const Duration(milliseconds: 280),
    reverseDuration:
        context.brix.toast.reverseDuration ?? const Duration(milliseconds: 200),
  )..forward();

  Timer? _timer;
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer ??= Timer(
      widget.duration ??
          context.brix.toast.duration ??
          BrixToast.defaultDuration,
      _close,
    );
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    await _controller.reverse();
    if (mounted) widget.onClosed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = context.brix.toast;
    final position = style.position ?? BrixToastPosition.top;
    final margin =
        style.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final safe = MediaQuery.paddingOf(context);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final card = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: style.maxWidth ?? 500),
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: _close,
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              final hide = switch (position) {
                BrixToastPosition.bottom => velocity > 0,
                BrixToastPosition.top => velocity < 0,
                _ => velocity != 0,
              };
              if (hide) _close();
            },
            child: widget.child(_close),
          ),
        ),
      ),
    );

    if (position == BrixToastPosition.center) {
      return Positioned.fill(
        left: margin.left,
        right: margin.right,
        // Only the card takes taps; the screen around it stays usable.
        child: Align(
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
              child: card,
            ),
          ),
        ),
      );
    }

    final bottom = position == BrixToastPosition.bottom;
    return Positioned(
      top: bottom ? null : safe.top + margin.top,
      bottom: bottom ? safe.bottom + margin.bottom : null,
      left: margin.left,
      right: margin.right,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0, bottom ? 1.4 : -1.4),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: card),
      ),
    );
  }
}
