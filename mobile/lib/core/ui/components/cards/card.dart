import 'package:flutter/material.dart';

enum CardType { primary, secondary, success, danger, warning, info, defaultType }

class AppCard extends StatelessWidget {
  final CardType? type;
  final Widget? image;
  final Widget? header;
  final Widget? child; // equates to default slot / body
  final Widget? footer;
  final bool noBody;
  final bool shadow;
  final bool hover;

  const AppCard({
    super.key,
    this.type,
    this.image,
    this.header,
    this.child,
    this.footer,
    this.noBody = false,
    this.shadow = true,
    this.hover = false,
  });

  Color _getBackgroundColor(BuildContext context) {
    if (type == null) return Theme.of(context).cardColor;
    switch (type!) {
      case CardType.primary: return Theme.of(context).primaryColor;
      case CardType.secondary: return Colors.grey.shade600;
      case CardType.success: return Colors.green;
      case CardType.danger: return Colors.red;
      case CardType.warning: return Colors.orange;
      case CardType.info: return Colors.lightBlue;
      case CardType.defaultType: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (image != null) image!,
        if (header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              child: header!,
            ),
          ),
        if (header != null && child != null && !noBody)
          const Divider(height: 1),
        if (child != null && !noBody)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: child!,
          ),
        if (child != null && noBody)
          child!,
        if (footer != null) ...[
          if (!noBody) const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: footer!,
          ),
        ],
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: hover
            ? InkWell(
                onTap: () {}, // Handled by parent typically, but activates hover/ripple
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }
}
