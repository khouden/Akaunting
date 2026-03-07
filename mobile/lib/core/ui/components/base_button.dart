import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, success, danger, warning, info, light, dark, defaultType }
enum ButtonSize { sm, md, lg }

class BaseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final bool round;
  final bool icon;
  final bool block;
  final bool loading;
  final bool wide;
  final bool disabled;
  final ButtonType type;
  final ButtonSize size;
  final bool outline;
  final bool link;
  final IconData? iconData;

  const BaseButton({
    super.key,
    required this.onPressed,
    this.child,
    this.round = false,
    this.icon = false,
    this.block = false,
    this.loading = false,
    this.wide = false,
    this.disabled = false,
    this.type = ButtonType.defaultType,
    this.size = ButtonSize.md,
    this.outline = false,
    this.link = false,
    this.iconData,
  });

  Color _getBackgroundColor(BuildContext context) {
    if (outline || link) return Colors.transparent;
    switch (type) {
      case ButtonType.primary: return Theme.of(context).primaryColor;
      case ButtonType.secondary: return Colors.grey.shade600;
      case ButtonType.success: return Colors.green;
      case ButtonType.danger: return Colors.red;
      case ButtonType.warning: return Colors.orange;
      case ButtonType.info: return Colors.lightBlue;
      case ButtonType.light: return Colors.grey.shade200;
      case ButtonType.dark: return Colors.grey.shade900;
      case ButtonType.defaultType: return Colors.grey.shade300;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (link) return Theme.of(context).primaryColor;
    if (outline) return _getSolidColor(context);
    switch (type) {
      case ButtonType.light:
      case ButtonType.defaultType:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  Color _getSolidColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary: return Theme.of(context).primaryColor;
      case ButtonType.secondary: return Colors.grey.shade600;
      case ButtonType.success: return Colors.green;
      case ButtonType.danger: return Colors.red;
      case ButtonType.warning: return Colors.orange;
      case ButtonType.info: return Colors.lightBlue;
      case ButtonType.light: return Colors.grey.shade200;
      case ButtonType.dark: return Colors.grey.shade900;
      case ButtonType.defaultType: return Colors.grey.shade500;
    }
  }

  EdgeInsets _getPadding() {
    if (link) return EdgeInsets.zero;
    if (icon) return const EdgeInsets.all(12);
    
    double horizontal = wide ? 32.0 : 16.0;
    double vertical = 10.0;
    
    switch (size) {
      case ButtonSize.sm:
        horizontal = wide ? 24.0 : 12.0;
        vertical = 6.0;
        break;
      case ButtonSize.lg:
        horizontal = wide ? 40.0 : 20.0;
        vertical = 14.0;
        break;
      case ButtonSize.md:
        break;
    }
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);
    final borderColor = outline ? _getSolidColor(context) : Colors.transparent;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
          ),
          if (child != null) const SizedBox(width: 8),
        ],
        if (!loading && iconData != null) ...[
          Icon(iconData, color: textColor, size: 18),
          if (child != null) const SizedBox(width: 8),
        ],
        if (child != null)
          DefaultTextStyle.merge(
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            child: child!,
          ),
      ],
    );

    ShapeBorder shape;
    if (round || icon) {
      shape = const StadiumBorder(); // or CircleBorder if only icon and totally round
    } else {
      shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    }

    if (outline) {
      shape = RoundedRectangleBorder(
        borderRadius: round ? BorderRadius.circular(50) : BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1.5),
      );
    }

    Widget btn;
    if (link) {
      btn = TextButton(
        onPressed: disabled || loading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: _getPadding(),
          shape: shape as OutlinedBorder,
          foregroundColor: textColor,
        ),
        child: buttonContent,
      );
    } else if (outline) {
      btn = OutlinedButton(
        onPressed: disabled || loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: _getPadding(),
          shape: shape as OutlinedBorder,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: buttonContent,
      );
    } else {
      btn = ElevatedButton(
        onPressed: disabled || loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: _getPadding(),
          shape: shape as OutlinedBorder,
          elevation: 0,
        ),
        child: buttonContent,
      );
    }

    if (block) {
      btn = SizedBox(width: double.infinity, child: btn);
    }

    return btn;
  }
}
