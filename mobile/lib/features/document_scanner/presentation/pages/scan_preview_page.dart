import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/scanned_document_data.dart';
import '../widgets/confidence_indicator.dart';

class ScanPreviewPage extends StatefulWidget {
	final ScannedDocumentData scannedData;
	final List<String> imagePaths;

	const ScanPreviewPage({
		super.key,
		required this.scannedData,
		required this.imagePaths,
	});

	@override
	State<ScanPreviewPage> createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
	final _formKey = GlobalKey<FormState>();

	late TextEditingController _numberController;
	late TextEditingController _amountController;
	late TextEditingController _contactController;
	late TextEditingController _currencyController;
	late TextEditingController _statusController;
	late TextEditingController _issueDateController;
	late TextEditingController _dueDateController;

	@override
	void initState() {
		super.initState();
		_numberController = TextEditingController(text: widget.scannedData.documentNumber ?? '');
		_amountController = TextEditingController(
			text: widget.scannedData.amount?.toStringAsFixed(2) ?? '',
		);
		_contactController = TextEditingController(text: widget.scannedData.contactName ?? '');
		_currencyController = TextEditingController(text: widget.scannedData.currencyCode ?? '');
		_statusController = TextEditingController(text: widget.scannedData.status ?? '');
		_issueDateController = TextEditingController(
			text: widget.scannedData.issueDate != null
					? DateFormat('yyyy-MM-dd').format(widget.scannedData.issueDate!)
					: '',
		);
		_dueDateController = TextEditingController(
			text: widget.scannedData.dueDate != null
					? DateFormat('yyyy-MM-dd').format(widget.scannedData.dueDate!)
					: '',
		);
	}

	@override
	void dispose() {
		_numberController.dispose();
		_amountController.dispose();
		_contactController.dispose();
		_currencyController.dispose();
		_statusController.dispose();
		_issueDateController.dispose();
		_dueDateController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final scannedData = widget.scannedData;

		return Scaffold(
			appBar: AppBar(
				title: const Text('Review Scanned Data'),
			),
			body: SafeArea(
				child: Form(
					key: _formKey,
					child: ListView(
						padding: const EdgeInsets.all(16),
						children: [
							if (scannedData.warnings.isNotEmpty)
								_buildWarningsCard(scannedData.warnings),
							if (scannedData.warnings.isNotEmpty) const SizedBox(height: 16),
							TextFormField(
								controller: _numberController,
								decoration: const InputDecoration(
									labelText: 'Document Number',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 8),
							ConfidenceIndicator(
								label: 'Document number confidence',
								confidence: scannedData.fieldConfidence['documentNumber'] ?? 0.0,
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _amountController,
								keyboardType: const TextInputType.numberWithOptions(decimal: true),
								decoration: const InputDecoration(
									labelText: 'Amount',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 8),
							ConfidenceIndicator(
								label: 'Amount confidence',
								confidence: scannedData.fieldConfidence['amount'] ?? 0.0,
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _contactController,
								decoration: const InputDecoration(
									labelText: 'Contact Name',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 8),
							ConfidenceIndicator(
								label: 'Contact confidence',
								confidence: scannedData.fieldConfidence['contactName'] ?? 0.0,
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _currencyController,
								textCapitalization: TextCapitalization.characters,
								decoration: const InputDecoration(
									labelText: 'Currency Code',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 8),
							ConfidenceIndicator(
								label: 'Currency confidence',
								confidence: scannedData.fieldConfidence['currencyCode'] ?? 0.0,
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _statusController,
								decoration: const InputDecoration(
									labelText: 'Status',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _issueDateController,
								decoration: const InputDecoration(
									labelText: 'Issue Date (yyyy-MM-dd)',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 8),
							ConfidenceIndicator(
								label: 'Issue date confidence',
								confidence: scannedData.fieldConfidence['issueDate'] ?? 0.0,
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _dueDateController,
								decoration: const InputDecoration(
									labelText: 'Due Date (yyyy-MM-dd)',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 8),
							ConfidenceIndicator(
								label: 'Due date confidence',
								confidence: scannedData.fieldConfidence['dueDate'] ?? 0.0,
							),
							const SizedBox(height: 24),
							ElevatedButton.icon(
								onPressed: _confirm,
								icon: const Icon(Icons.check_circle_outline),
								label: const Text('Confirm and Fill Form'),
							),
							const SizedBox(height: 8),
							TextButton(
								onPressed: () => Navigator.of(context).pop(),
								child: const Text('Cancel'),
							),
						],
					),
				),
			),
		);
	}

	Widget _buildWarningsCard(List<String> warnings) {
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: Colors.orange.withValues(alpha: 0.08),
				borderRadius: BorderRadius.circular(10),
				border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Review recommended',
						style: TextStyle(fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 8),
					...warnings.map((warning) => Padding(
								padding: const EdgeInsets.only(bottom: 4),
								child: Text('• $warning'),
							)),
				],
			),
		);
	}

	void _confirm() {
		DateTime? issueDate;
		DateTime? dueDate;

		if (_issueDateController.text.trim().isNotEmpty) {
			issueDate = _tryParseDate(_issueDateController.text.trim());
		}
		if (_dueDateController.text.trim().isNotEmpty) {
			dueDate = _tryParseDate(_dueDateController.text.trim());
		}

		final reviewed = widget.scannedData.copyWith(
			documentNumber: _numberController.text.trim().isEmpty ? null : _numberController.text.trim(),
			amount: double.tryParse(_amountController.text.trim()),
			contactName: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
			currencyCode: _currencyController.text.trim().isEmpty ? null : _currencyController.text.trim().toUpperCase(),
			status: _statusController.text.trim().isEmpty ? null : _statusController.text.trim().toLowerCase(),
			issueDate: issueDate,
			dueDate: dueDate,
		);

		Navigator.of(context).pop(reviewed);
	}

	DateTime? _tryParseDate(String value) {
		const formats = [
			'yyyy-MM-dd',
			'dd/MM/yyyy',
			'MM/dd/yyyy',
			'dd-MM-yyyy',
			'MM-dd-yyyy',
		];

		for (final format in formats) {
			try {
				return DateFormat(format).parseStrict(value);
			} catch (_) {
				// Try next format.
			}
		}
		return null;
	}
}
