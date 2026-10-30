import 'package:flutter/material.dart';

import '../theme/brix_theme.dart';
import 'brix_field_border.dart';
import 'brix_text_field_style.dart';

/// The shared look of brix form fields (text field, select), so they always
/// match. Internal to brix_ui.
class BrixFieldLook {
  BrixFieldLook(this.brix, this.style);

  final BrixTheme brix;
  final BrixTextFieldStyle style;

  bool get labelInside => style.labelInside ?? false;

  TextStyle get labelStyle => brix.typography.label
      .copyWith(color: brix.colors.text)
      .merge(style.labelStyle);

  TextStyle textStyle({required bool enabled}) => brix.typography.body
      .copyWith(color: enabled ? brix.colors.text : brix.colors.mutedText)
      .merge(style.textStyle);

  TextStyle get hintStyle => brix.typography.body
      .copyWith(color: brix.colors.mutedText)
      .merge(style.hintStyle);

  /// The label with the required marker, or `null` without a label.
  Widget? label(String? text, {required bool isRequired}) {
    if (text == null) return null;
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          if (isRequired && style.requiredMarker != '')
            TextSpan(
              text: style.requiredMarker ?? ' *',
              style: TextStyle(color: brix.colors.danger)
                  .merge(style.requiredMarkerStyle),
            ),
        ],
      ),
      style: labelStyle,
    );
  }

  InputDecoration decoration({
    required bool canType,
    Widget? label,
    String? hint,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final colors = brix.colors;
    final shape = brix.shape;
    final edge = style.border ?? BrixFieldBorder.outline;
    final width = style.borderWidth ?? shape.borderWidth;
    final focusedWidth = style.focusedBorderWidth ?? width * 1.5;
    final radius = BorderRadius.circular(style.radius ?? shape.radius);

    InputBorder border(Color color, double width) => switch (edge) {
      BrixFieldBorder.underline => UnderlineInputBorder(
        borderSide: BorderSide(color: color, width: width),
      ),
      BrixFieldBorder.none => OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      _ => OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      ),
    };

    return InputDecoration(
      label: labelInside ? label : null,
      floatingLabelStyle: labelInside
          ? labelStyle.copyWith(color: colors.primary)
          : null,
      hintText: hint,
      hintStyle: hintStyle,
      errorText: errorText,
      errorStyle: brix.typography.caption
          .copyWith(color: colors.danger)
          .merge(style.errorStyle),
      errorMaxLines: style.errorMaxLines ?? 3,
      prefixIcon: prefixIcon,
      prefixIconColor: colors.mutedText,
      suffixIcon: suffixIcon,
      suffixIconColor: colors.mutedText,
      filled: style.filled ?? edge != BrixFieldBorder.underline,
      fillColor:
          style.fillColor ?? (canType ? colors.surface : colors.background),
      counterText: '',
      isDense: true,
      constraints: BoxConstraints(minHeight: style.height ?? shape.fieldHeight),
      contentPadding: style.contentPadding ?? const EdgeInsets.all(14),
      border: border(colors.border, width),
      enabledBorder: border(colors.border, width),
      disabledBorder: border(colors.border, width),
      focusedBorder: canType
          ? border(colors.primary, focusedWidth)
          : border(colors.border, width),
      errorBorder: border(colors.danger, width),
      focusedErrorBorder: border(colors.danger, canType ? focusedWidth : width),
    );
  }

  /// [field] with its label above it (or alone when the label is inside).
  /// The label is read with the field by screen readers.
  Widget withLabel(Widget field, Widget? label, String? labelText) {
    if (label == null || labelInside) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: label),
        SizedBox(height: style.labelGap ?? 8),
        Semantics(label: labelText, child: field),
      ],
    );
  }
}
