import 'package:equatable/equatable.dart';

class ScannedDocumentData extends Equatable {
	final String? documentNumber;
	final double? amount;
	final DateTime? issueDate;
	final DateTime? dueDate;
	final String? contactName;
	final String? currencyCode;
	final String? status;
	final String rawText;
	final Map<String, double> fieldConfidence;
	final List<String> warnings;

	const ScannedDocumentData({
		this.documentNumber,
		this.amount,
		this.issueDate,
		this.dueDate,
		this.contactName,
		this.currencyCode,
		this.status,
		required this.rawText,
		this.fieldConfidence = const {},
		this.warnings = const [],
	});

	bool get hasAnyData {
		return (documentNumber?.isNotEmpty ?? false) ||
				amount != null ||
				issueDate != null ||
				dueDate != null ||
				(contactName?.isNotEmpty ?? false) ||
				(currencyCode?.isNotEmpty ?? false) ||
				(status?.isNotEmpty ?? false);
	}

	double get overallConfidence {
		if (fieldConfidence.isEmpty) return 0;
		final total = fieldConfidence.values.fold<double>(0, (sum, value) => sum + value);
		return total / fieldConfidence.length;
	}

	ScannedDocumentData copyWith({
		String? documentNumber,
		double? amount,
		DateTime? issueDate,
		DateTime? dueDate,
		String? contactName,
		String? currencyCode,
		String? status,
		String? rawText,
		Map<String, double>? fieldConfidence,
		List<String>? warnings,
	}) {
		return ScannedDocumentData(
			documentNumber: documentNumber ?? this.documentNumber,
			amount: amount ?? this.amount,
			issueDate: issueDate ?? this.issueDate,
			dueDate: dueDate ?? this.dueDate,
			contactName: contactName ?? this.contactName,
			currencyCode: currencyCode ?? this.currencyCode,
			status: status ?? this.status,
			rawText: rawText ?? this.rawText,
			fieldConfidence: fieldConfidence ?? this.fieldConfidence,
			warnings: warnings ?? this.warnings,
		);
	}

	@override
	List<Object?> get props => [
				documentNumber,
				amount,
				issueDate,
				dueDate,
				contactName,
				currencyCode,
				status,
				rawText,
				fieldConfidence,
				warnings,
			];
}
