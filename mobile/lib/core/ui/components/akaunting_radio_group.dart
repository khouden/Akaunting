import 'package:flutter/material.dart';

class AkauntingRadioGroup extends StatelessWidget {
  final String? text;
  final int value;
  final String enableText;
  final String disableText;
  final ValueChanged<int>? onChanged;
  final bool disabled;

  const AkauntingRadioGroup({
    super.key,
    this.text,
    required this.value,
    this.enableText = 'Yes',
    this.disableText = 'No',
    this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              text!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: disabled ? null : () => onChanged?.call(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: value == 1 ? Theme.of(context).primaryColor : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      enableText,
                      style: TextStyle(
                        color: value == 1 ? Colors.white : Colors.black87,
                        fontWeight: value == 1 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: disabled ? null : () => onChanged?.call(0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: value == 0 ? Colors.red : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      disableText,
                      style: TextStyle(
                        color: value == 0 ? Colors.white : Colors.black87,
                        fontWeight: value == 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
