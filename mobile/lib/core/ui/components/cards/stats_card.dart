import 'package:flutter/material.dart';
import 'card.dart';

class StatsCard extends StatelessWidget {
  final CardType type;
  final IconData? icon;
  final String? title;
  final String? subTitle;
  final Widget? footer;

  const StatsCard({
    super.key,
    this.type = CardType.primary,
    this.icon,
    this.title,
    this.subTitle,
    this.footer,
  });

  Color _getIconBackgroundColor(BuildContext context) {
    switch (type) {
      case CardType.primary: return Theme.of(context).primaryColor;
      case CardType.secondary: return Colors.grey.shade600;
      case CardType.success: return Colors.green;
      case CardType.danger: return Colors.red;
      case CardType.warning: return Colors.orange;
      case CardType.info: return Colors.lightBlue;
      case CardType.defaultType: return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (title != null && subTitle != null) const SizedBox(height: 4),
                    if (subTitle != null)
                      Text(
                        subTitle!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(context),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getIconBackgroundColor(context).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ],
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 16),
            DefaultTextStyle.merge(
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
