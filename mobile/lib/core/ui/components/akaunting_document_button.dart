import 'package:flutter/material.dart';

class AkauntingDocumentButton extends StatelessWidget {
  final String addItemText;
  final VoidCallback onPressed;

  const AkauntingDocumentButton({
    super.key,
    this.addItemText = 'Add an item',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
        label: Text(
          addItemText,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(),
        ),
      ),
    );
  }
}
