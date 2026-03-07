import 'package:flutter/material.dart';

class AkauntingDropzoneFileUpload extends StatelessWidget {
  final String textDropFile;
  final String textChooseFile;
  final VoidCallback? onChooseFile;
  final List<String> files;
  final String? error;

  const AkauntingDropzoneFileUpload({
    super.key,
    this.textDropFile = 'Drop files here to upload',
    this.textChooseFile = 'Choose File',
    this.onChooseFile,
    this.files = const [],
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onChooseFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: error != null ? Colors.red : Colors.grey.shade300,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  textDropFile,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  textChooseFile,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...files.map((file) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(file, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )),
        ]
      ],
    );
  }
}
