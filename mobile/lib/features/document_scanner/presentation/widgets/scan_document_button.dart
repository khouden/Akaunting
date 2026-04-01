import 'package:flutter/material.dart';

import '../cubit/document_scanner_state.dart';

class ScanDocumentButton extends StatelessWidget {
	final VoidCallback onPressed;
	final DocumentScannerState state;

	const ScanDocumentButton({
		super.key,
		required this.onPressed,
		required this.state,
	});

	@override
	Widget build(BuildContext context) {
		final isLoading = state is DocumentScannerInProgress;
		final progressMessage = state is DocumentScannerInProgress
				? (state as DocumentScannerInProgress).message
				: null;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.stretch,
			children: [
				OutlinedButton.icon(
					onPressed: isLoading ? null : onPressed,
					icon: isLoading
							? const SizedBox(
									width: 18,
									height: 18,
									child: CircularProgressIndicator(strokeWidth: 2),
								)
							: const Icon(Icons.document_scanner_outlined),
					label: Text(isLoading ? 'Processing scan...' : 'Scan Paper Document'),
					style: OutlinedButton.styleFrom(
						padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
					),
				),
				if (progressMessage != null) ...[
					const SizedBox(height: 8),
					Text(
						progressMessage,
						textAlign: TextAlign.center,
						style: Theme.of(context).textTheme.bodySmall?.copyWith(
									color: Colors.grey.shade700,
								),
					),
				],
			],
		);
	}
}
