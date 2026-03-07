import 'package:flutter/material.dart';

enum BadgeType { primary, info, danger, defaultType, warning, success }
enum BadgeSize { defaultSize, md, lg }

class AppBadge extends StatelessWidget {
  final Widget? child;
  final bool rounded; // pill type
  final bool circle; // circle
  final IconData? icon;
  final BadgeType type;
  final BadgeSize size;

  const AppBadge({
    super.key,
    this.child,
    this.rounded = false,
    this.circle = false,
    this.icon,
    this.type = BadgeType.defaultType,
    this.size = BadgeSize.defaultSize,
  });

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case BadgeType.primary: return Theme.of(context).primaryColor;
      case BadgeType.info: return Colors.lightBlue;
      case BadgeType.danger: return Colors.red;
      case BadgeType.warning: return Colors.orange;
      case BadgeType.success: return Colors.green;
      case BadgeType.defaultType: return Colors.grey.shade400;
    }
  }

  Color _getTextColor() => Colors.white;

  EdgeInsets _getPadding() {
    if (circle) return const EdgeInsets.all(8);
    switch (size) {
      case BadgeSize.lg: return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case BadgeSize.md: return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case BadgeSize.defaultSize: return const EdgeInsets.symmetric(horizontal: 8, vertical: 2);
    }
  }

  double _getFontSize() {
    switch (size) {
      case BadgeSize.lg: return 14;
      case BadgeSize.md: return 12;
      case BadgeSize.defaultSize: return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(context);
    final textColor = _getTextColor();

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _getFontSize() + 2, color: textColor),
          if (child != null) const SizedBox(width: 4),
        ],
        if (child != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: textColor,
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
            child: child!,
          ),
      ],
    );

    BorderRadiusGeometry borderRadius;
    if (circle) {
      borderRadius = BorderRadius.circular(100);
    } else if (rounded) {
      borderRadius = BorderRadius.circular(50); // pill
    } else {
      borderRadius = BorderRadius.circular(4); // default slightly rounded
    }

    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
      ),
      child: content,
    );
  }
}
