import 'package:flutter/material.dart';

import '../theme/brix_theme_context.dart';
import 'brix_field_look.dart';
import 'brix_option.dart';
import 'brix_select_data.dart';
import 'brix_select_mode.dart';
import 'brix_select_style.dart';
import 'brix_sheet.dart';
import 'brix_text_field_style.dart';

/// A dropdown that looks like a `BrixTextField`: label above, the chosen
/// option inside, a chevron at the end. Tapping it shows the options in a
/// menu under the field (up to six) or in a `BrixSheet` (more), with a tick
/// next to the chosen one.
///
/// ```dart
/// BrixSelect<String>(
///   label: 'Country',
///   isRequired: true,
///   value: country,
///   options: const [
///     BrixOption(value: 'pk', label: 'Pakistan'),
///     BrixOption(value: 'gb', label: 'United Kingdom'),
///   ],
///   onChanged: (value) => setState(() => country = value),
/// )
/// ```
///
/// Inside a `Form`, a required select with no [validator] checks that
/// something is chosen. The field follows `BrixTheme.textField`; the menu
/// and sheet follow `BrixTheme.select`. Draw a completely own field with
/// [builder] (or `BrixTheme.selectBuilder`).
class BrixSelect<T> extends StatefulWidget {
  const BrixSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.isRequired = false,
    this.requiredMessage,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.mode = BrixSelectMode.auto,
    this.sheetTitle,
    this.style,
    this.fieldStyle,
    this.builder,
  });

  final List<BrixOption<T>> options;

  /// The chosen value; `null` shows [hint].
  final T? value;

  /// Called with the chosen value.
  final ValueChanged<T>? onChanged;

  /// Shown above the field.
  final String? label;

  /// Shown while nothing is chosen. Default: the theme's `selectHint`.
  final String? hint;

  /// Adds the required marker and, without a [validator], a check that
  /// something is chosen.
  final bool isRequired;

  /// Default: the theme's `requiredField` text.
  final String? requiredMessage;

  final FormFieldValidator<T>? validator;

  /// An error from outside the form (e.g. the backend).
  final String? errorText;

  final bool enabled;
  final BrixSelectMode mode;

  /// Title of the sheet. Default: [label].
  final String? sheetTitle;

  /// This select's menu and sheet look, on top of `BrixTheme.select`.
  final BrixSelectStyle? style;

  /// This field's look, on top of `BrixTheme.textField`.
  final BrixTextFieldStyle? fieldStyle;

  /// Draws this field instead of brix (wins over `BrixTheme.selectBuilder`).
  final BrixSelectBuilder<T>? builder;

  @override
  State<BrixSelect<T>> createState() => _BrixSelectState<T>();
}

class _BrixSelectState<T> extends State<BrixSelect<T>> {
  final _field = GlobalKey<FormFieldState<T>>();
  final _menu = MenuController();

  @override
  void didUpdateWidget(BrixSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      // The field shows the app's new value from the next frame on.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final field = _field.currentState;
        if (mounted && field != null && field.value != widget.value) {
          field.didChange(widget.value);
        }
      });
    }
  }

  bool get _useMenu => switch (widget.mode) {
    BrixSelectMode.menu => true,
    BrixSelectMode.sheet => false,
    _ => widget.options.length <= 6,
  };

  BrixOption<T>? _optionFor(T? value) {
    for (final option in widget.options) {
      if (option.value == value) return option;
    }
    return null;
  }

  void _pick(T value) {
    _field.currentState?.didChange(value);
    widget.onChanged?.call(value);
  }

  Future<void> _open() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_useMenu) {
      _menu.isOpen ? _menu.close() : _menu.open();
      return;
    }
    final current = _field.currentState?.value;
    final picked = await BrixSheet.show<_Picked<T>>(
      context: context,
      title: widget.sheetTitle ?? widget.label,
      builder: (sheetContext) => _OptionList<T>(
        options: widget.options,
        selected: current,
        style: context.brix.select.merge(widget.style),
        onTap: (value) => BrixSheet.close(sheetContext, _Picked(value)),
      ),
    );
    if (picked != null && mounted) _pick(picked.value);
  }

  String? _validate(T? value) {
    if (widget.validator != null) return widget.validator!(value);
    if (widget.isRequired && value == null) {
      return widget.requiredMessage ?? context.brix.texts.requiredField;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final style = brix.select.merge(widget.style);

    final field = FormField<T>(
      key: _field,
      initialValue: widget.value,
      validator: _validate,
      enabled: widget.enabled,
      builder: (state) {
        final data = BrixSelectData<T>(
          label: widget.label,
          hint: widget.hint ?? brix.texts.selectHint,
          value: state.value,
          selected: _optionFor(state.value),
          options: widget.options,
          open: widget.enabled ? _open : null,
          errorText: state.errorText ?? widget.errorText,
          isRequired: widget.isRequired,
          enabled: widget.enabled,
          style: style,
        );
        final custom = widget.builder ?? brix.selectBuilder;
        if (custom != null) return custom(context, data);
        return _DefaultField<T>(data: data, fieldStyle: widget.fieldStyle);
      },
    );

    if (!_useMenu) return field;

    final selected = _field.currentState?.value ?? widget.value;
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: _menu,
        alignmentOffset: const Offset(0, 6),
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            style.menuColor ?? brix.colors.surface,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shadowColor: const WidgetStatePropertyAll(Color(0x40000000)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 6),
          ),
          minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 0)),
          maximumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth, style.menuMaxHeight ?? 320),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                style.menuRadius ?? brix.shape.radius,
              ),
            ),
          ),
        ),
        menuChildren: [
          for (final option in widget.options)
            MenuItemButton(
              onPressed: () => _pick(option.value),
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  style.optionPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                minimumSize: WidgetStatePropertyAll(
                  Size(constraints.maxWidth, 44),
                ),
              ),
              leadingIcon: option.icon?.build(
                color: brix.colors.mutedText,
                size: 20,
              ),
              trailingIcon: option.value == selected
                  ? brix.icons.selected.build(
                      color: style.selectedColor ?? brix.colors.primary,
                      size: 20,
                    )
                  : null,
              child: Text(
                option.label,
                style: brix.typography.body
                    .copyWith(color: brix.colors.text)
                    .merge(style.optionStyle),
              ),
            ),
        ],
        child: field,
      ),
    );
  }
}

/// A value picked in the sheet, so a `null` value is not taken for
/// "closed without picking".
class _Picked<T> {
  const _Picked(this.value);

  final T value;
}

/// The brix field: the text field look with the chosen label and a chevron.
class _DefaultField<T> extends StatelessWidget {
  const _DefaultField({required this.data, required this.fieldStyle});

  final BrixSelectData<T> data;
  final BrixTextFieldStyle? fieldStyle;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final look = BrixFieldLook(brix, brix.textField.merge(fieldStyle));
    final label = look.label(data.label, isRequired: data.isRequired);
    final radius = BorderRadius.circular(
      look.style.radius ?? brix.shape.radius,
    );
    final field = Semantics(
      button: true,
      enabled: data.enabled,
      value: data.selected?.label,
      child: InkWell(
        onTap: data.open,
        borderRadius: radius,
        child: InputDecorator(
          isEmpty: data.selected == null,
          decoration: look.decoration(
            canType: data.enabled,
            label: label,
            hint: data.hint,
            errorText: data.errorText,
            suffixIcon: brix.icons.selectChevron.build(
              color: brix.colors.mutedText,
              size: 20,
            ),
          ),
          child: Text(
            data.selected?.label ?? '',
            style: look.textStyle(enabled: data.enabled),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
    return look.withLabel(field, label, data.label);
  }
}

/// The options in a sheet: one row each, a tick on the chosen one.
class _OptionList<T> extends StatelessWidget {
  const _OptionList({
    required this.options,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  final List<BrixOption<T>> options;
  final T? selected;
  final BrixSelectStyle style;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0)
            Divider(height: 0.5, thickness: 0.5, color: brix.colors.border),
          InkWell(
            onTap: () => onTap(options[i].value),
            child: Padding(
              padding:
                  style.optionPadding ??
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              child: Row(
                children: [
                  if (options[i].icon != null) ...[
                    options[i].icon!.build(
                      color: brix.colors.mutedText,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      options[i].label,
                      style: brix.typography.body
                          .copyWith(fontSize: 17, color: brix.colors.text)
                          .merge(style.optionStyle),
                    ),
                  ),
                  if (options[i].value == selected)
                    brix.icons.selected.build(
                      color: style.selectedColor ?? brix.colors.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
