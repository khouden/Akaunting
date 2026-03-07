import 'package:flutter/material.dart';

class AkauntingSwitch extends StatelessWidget {
  final String? label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AkauntingSwitch({
    super.key,
    this.label,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget switchWidget = GestureDetector(
      onTap: () {
        if (onChanged != null) onChanged!(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? Colors.green : Colors.grey.shade300,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              right: value ? 2 : 22,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (label != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label!,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          switchWidget,
        ],
      );
    }

    return switchWidget;
  }
}
