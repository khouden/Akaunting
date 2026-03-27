import 'package:flutter/material.dart';

class AkauntingSelectOption {
  final String key;
  final String value;

  AkauntingSelectOption({required this.key, required this.value});
}

class AkauntingSelect extends StatelessWidget {
  final String? title;
  final String? placeholder;
  final bool isRequired;
  final String? error;
  final List<AkauntingSelectOption> options;
  final String? value;
  final void Function(String?)? onChanged;
  final bool disabled;
  final IconData? icon;

  const AkauntingSelect({
    super.key,
    this.title,
    this.placeholder,
    this.isRequired = false,
    this.error,
    required this.options,
    this.value,
    this.onChanged,
    this.disabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Sanitize options to prevent duplicate keys
    final uniqueOptions = <AkauntingSelectOption>[];
    final seenKeys = <String>{};
    for (var opt in options) {
      if (!seenKeys.contains(opt.key)) {
        seenKeys.add(opt.key);
        uniqueOptions.add(opt);
      }
    }

    // Ensure value exists in options to prevent 'Either zero or 2 or more' assertion
    String? safeValue = value;
    if (safeValue != null && !seenKeys.contains(safeValue)) {
      safeValue = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              text: TextSpan(
                text: title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        DropdownButtonFormField<String>(
          value: safeValue,
          onChanged: disabled ? null : onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: disabled ? Colors.grey.shade200 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey.shade400, size: 20)
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorText: error,
          ),
          items: uniqueOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option.key,
              child: Text(option.value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

