import 'package:flutter/material.dart';

class AkauntingDate extends StatelessWidget {
  final String? title;
  final String? placeholder;
  final bool isRequired;
  final String? error;
  final String? value;
  final ValueChanged<DateTime?>? onChanged;
  final bool disabled;
  final IconData? icon;

  const AkauntingDate({
    super.key,
    this.title,
    this.placeholder,
    this.isRequired = false,
    this.error,
    this.value,
    this.onChanged,
    this.disabled = false,
    this.icon,
  });

  Future<void> _selectDate(BuildContext context) async {
    if (disabled) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && onChanged != null) {
      onChanged!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(text: value),
              enabled: !disabled,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: disabled ? Colors.grey.shade200 : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: icon != null
                    ? Icon(icon, color: Colors.grey.shade400, size: 20)
                    : null,
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
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
            ),
          ),
        ),
      ],
    );
  }
}
