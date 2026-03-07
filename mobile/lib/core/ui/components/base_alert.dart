import 'package:flutter/material.dart';

enum AlertType { primary, secondary, success, danger, warning, info, defaultType }

class BaseAlert extends StatefulWidget {
  final AlertType type;
  final bool dismissible;
  final IconData? icon;
  final Widget content;
  final VoidCallback? onDismissed;

  const BaseAlert({
    super.key,
    this.type = AlertType.defaultType,
    this.dismissible = false,
    this.icon,
    required this.content,
    this.onDismissed,
  });

  @override
  State<BaseAlert> createState() => _BaseAlertState();
}

class _BaseAlertState extends State<BaseAlert> with SingleTickerProviderStateMixin {
  bool _isVisible = true;

  void _dismiss() {
    setState(() {
      _isVisible = false;
    });
    if (widget.onDismissed != null) {
      widget.onDismissed!();
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (widget.type) {
      case AlertType.primary: return Theme.of(context).primaryColor.withOpacity(0.1);
      case AlertType.secondary: return Colors.grey.shade200;
      case AlertType.success: return Colors.green.withOpacity(0.1);
      case AlertType.danger: return Colors.red.withOpacity(0.1);
      case AlertType.warning: return Colors.orange.withOpacity(0.1);
      case AlertType.info: return Colors.lightBlue.withOpacity(0.1);
      case AlertType.defaultType: return Colors.grey.shade100;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (widget.type) {
      case AlertType.primary: return Theme.of(context).primaryColorDark;
      case AlertType.secondary: return Colors.grey.shade800;
      case AlertType.success: return Colors.green.shade800;
      case AlertType.danger: return Colors.red.shade800;
      case AlertType.warning: return Colors.orange.shade900;
      case AlertType.info: return Colors.lightBlue.shade800;
      case AlertType.defaultType: return Colors.grey.shade800;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (widget.type) {
      case AlertType.primary: return Theme.of(context).primaryColor.withOpacity(0.3);
      case AlertType.secondary: return Colors.grey.shade300;
      case AlertType.success: return Colors.green.withOpacity(0.3);
      case AlertType.danger: return Colors.red.withOpacity(0.3);
      case AlertType.warning: return Colors.orange.withOpacity(0.3);
      case AlertType.info: return Colors.lightBlue.withOpacity(0.3);
      case AlertType.defaultType: return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final bgColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);
    final borderColor = _getBorderColor(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: textColor, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: DefaultTextStyle.merge(
                style: TextStyle(color: textColor, fontSize: 14),
                child: widget.content,
              ),
            ),
            if (widget.dismissible) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _dismiss,
                child: Icon(Icons.close, color: textColor.withOpacity(0.7), size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
