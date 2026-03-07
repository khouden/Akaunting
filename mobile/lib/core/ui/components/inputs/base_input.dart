import 'package:flutter/material.dart';

class BaseInput extends StatelessWidget {
  final String? label;
  final bool isRequired;
  final String? error;
  final String? successMessage;
  final IconData? appendIcon;
  final IconData? prependIcon;
  final String? placeholder;
  final bool obscureText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool disabled;

  const BaseInput({
    super.key,
    this.label,
    this.isRequired = false,
    this.error,
    this.successMessage,
    this.appendIcon,
    this.prependIcon,
    this.placeholder,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              text: TextSpan(
                text: label,
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
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: !disabled,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: disabled ? Colors.grey.shade200 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: prependIcon != null
                ? Icon(prependIcon, color: Colors.grey.shade400, size: 20)
                : null,
            suffixIcon: appendIcon != null
                ? Icon(appendIcon, color: Colors.grey.shade400, size: 20)
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorText: error,
          ),
        ),
        if (error == null && successMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              successMessage!,
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
