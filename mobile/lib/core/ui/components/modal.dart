import 'package:flutter/material.dart';

enum ModalType { notice, mini, defaultType }
enum ModalSize { sm, lg, md }

class AppModal extends StatelessWidget {
  final Widget? header;
  final Widget content;
  final Widget? footer;
  final bool showClose;
  final ModalType type;
  final ModalSize size;

  const AppModal({
    super.key,
    this.header,
    required this.content,
    this.footer,
    this.showClose = true,
    this.type = ModalType.defaultType,
    this.size = ModalSize.md,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? header,
    required Widget content,
    Widget? footer,
    bool showClose = true,
    ModalType type = ModalType.defaultType,
    ModalSize size = ModalSize.md,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppModal(
        header: header,
        content: content,
        footer: footer,
        showClose: showClose,
        type: type,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = 500;
    if (size == ModalSize.sm || type == ModalType.mini) maxWidth = 300;
    if (size == ModalSize.lg) maxWidth = 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null || showClose)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    if (header != null)
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          child: header!,
                        ),
                      ),
                    if (header == null) const Spacer(),
                    if (showClose)
                      IconButton(
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(type == ModalType.notice ? 0 : 24),
                child: content,
              ),
            ),
            if (footer != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}
