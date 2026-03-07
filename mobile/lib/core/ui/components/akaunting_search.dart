import 'package:flutter/material.dart';

class AkauntingSearch extends StatelessWidget {
  final String placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AkauntingSearch({
    super.key,
    this.placeholder = 'Search or filter results...',
    this.value,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: value != null ? TextEditingController(text: value) : null,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: value != null && value!.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: onClear,
                )
              : const Icon(Icons.search, color: Colors.grey, size: 20),
        ),
      ),
    );
  }
}
