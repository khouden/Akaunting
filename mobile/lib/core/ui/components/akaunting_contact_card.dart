import 'package:flutter/material.dart';

class ContactData {
  final int id;
  final String name;
  final String? address;
  final String? taxNumber;
  final String? phone;
  final String? email;

  ContactData({
    required this.id,
    required this.name,
    this.address,
    this.taxNumber,
    this.phone,
    this.email,
  });
}

class AkauntingContactCard extends StatelessWidget {
  final ContactData? selectedContact;
  final VoidCallback onAddContact;
  final VoidCallback onEditContact;
  final VoidCallback onChangeContact;
  final String addContactText;
  final String contactInfoText;
  final String? error;

  const AkauntingContactCard({
    super.key,
    this.selectedContact,
    required this.onAddContact,
    required this.onEditContact,
    required this.onChangeContact,
    this.addContactText = 'Add a customer',
    this.contactInfoText = 'Bill to',
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedContact == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onAddContact,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: error != null ? Colors.red : Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_alt_1_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    addContactText,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contactInfoText,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          selectedContact!.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        if (selectedContact!.address != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(selectedContact!.address!, style: const TextStyle(fontSize: 12)),
          ),
        if (selectedContact!.taxNumber != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('Tax number: ${selectedContact!.taxNumber}', style: const TextStyle(fontSize: 12)),
          ),
        if (selectedContact!.phone != null || selectedContact!.email != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              [selectedContact!.phone, selectedContact!.email].where((e) => e != null).join(' - '),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              onPressed: onEditContact,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Edit ${selectedContact!.name}', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            TextButton(
              onPressed: onChangeContact,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Choose a different customer', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}
