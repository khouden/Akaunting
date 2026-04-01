import 'package:intl/intl.dart';

import '../../domain/entities/scanned_document_data.dart';
import '../../domain/services/document_parser_service.dart';

class DocumentParserServiceImpl implements DocumentParserService {
	@override
	ScannedDocumentData parse(String rawText) {
		final normalized = rawText.replaceAll('\r', '');
		final lower = normalized.toLowerCase();
		final warnings = <String>[];
		final confidence = <String, double>{};

		final documentNumber = _extractDocumentNumber(normalized);
		if (documentNumber != null) {
			confidence['documentNumber'] = 0.86;
		} else {
			warnings.add('Document number could not be detected.');
		}

		final amount = _extractAmount(normalized);
		if (amount != null) {
			confidence['amount'] = 0.82;
		} else {
			warnings.add('Amount could not be detected reliably.');
		}

		final issueDate = _extractIssueDate(normalized);
		if (issueDate != null) {
			confidence['issueDate'] = 0.8;
		}

		final dueDate = _extractDueDate(normalized);
		if (dueDate != null) {
			confidence['dueDate'] = 0.78;
		}

		if (issueDate == null && dueDate == null) {
			warnings.add('Dates were not detected.');
		}

		final contactName = _extractContactName(normalized);
		if (contactName != null) {
			confidence['contactName'] = 0.65;
		}

		final currencyCode = _extractCurrencyCode(normalized);
		if (currencyCode != null) {
			confidence['currencyCode'] = 0.7;
		}

		final status = _extractStatus(lower);
		if (status != null) {
			confidence['status'] = 0.72;
		}

		if (normalized.trim().length < 40) {
			warnings.add('Extracted text is very short. Image quality may be low.');
		}

		return ScannedDocumentData(
			documentNumber: documentNumber,
			amount: amount,
			issueDate: issueDate,
			dueDate: dueDate,
			contactName: contactName,
			currencyCode: currencyCode,
			status: status,
			rawText: rawText,
			fieldConfidence: confidence,
			warnings: warnings,
		);
	}

	String? _extractDocumentNumber(String text) {
		final patterns = [
			RegExp(r'(?:invoice|document|bill)\s*(?:number|no|#)\s*[:\-]?\s*([A-Z0-9\-_/]+)', caseSensitive: false),
			RegExp(r'\b(?:inv|doc)[\-\s]?([0-9]{3,}|[A-Z0-9\-_/]{4,})\b', caseSensitive: false),
		];

		for (final pattern in patterns) {
			final match = pattern.firstMatch(text);
			if (match != null) {
				final value = match.group(1)?.trim();
				if (value != null && value.isNotEmpty) {
					return value;
				}
			}
		}
		return null;
	}

	double? _extractAmount(String text) {
		final amountPatterns = [
			RegExp(r'(?:total\s*due|grand\s*total|amount\s*due|total)\s*[:\-]?\s*([\$€£]?\s*[0-9][0-9,\.\s]*)', caseSensitive: false),
			RegExp(r'([\$€£]\s*[0-9][0-9,\.\s]*)'),
		];

		for (final pattern in amountPatterns) {
			final match = pattern.firstMatch(text);
			if (match == null) continue;
			final token = match.group(1);
			if (token == null) continue;
			final parsed = _toDouble(token);
			if (parsed != null && parsed > 0) {
				return parsed;
			}
		}
		return null;
	}

	double? _toDouble(String value) {
		var cleaned = value.replaceAll(RegExp(r'[^0-9,\.]'), '');
		if (cleaned.isEmpty) return null;

		final hasComma = cleaned.contains(',');
		final hasDot = cleaned.contains('.');

		if (hasComma && hasDot) {
			if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
				cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
			} else {
				cleaned = cleaned.replaceAll(',', '');
			}
		} else if (hasComma && !hasDot) {
			final commaCount = ','.allMatches(cleaned).length;
			if (commaCount == 1 && cleaned.split(',').last.length <= 2) {
				cleaned = cleaned.replaceAll(',', '.');
			} else {
				cleaned = cleaned.replaceAll(',', '');
			}
		}

		return double.tryParse(cleaned);
	}

	DateTime? _extractIssueDate(String text) {
		const dateTokenPattern =
				r'((?:[0-9]{4}[\-/][0-9]{1,2}[\-/][0-9]{1,2})|(?:[0-9]{1,2}[\-/][0-9]{1,2}[\-/][0-9]{2,4}))';
		final patterns = [
			RegExp(
				'(?:invoice\\s*date|issue\\s*date|issued\\s*on|date)\\s*[:\\-]?\\s*$dateTokenPattern',
				caseSensitive: false,
			),
			RegExp(r'(?:invoice\s*date|issue\s*date|issued\s*on|date)\s*[:\-]?\s*([A-Za-z]{3,9}\s+[0-9]{1,2},?\s+[0-9]{4})', caseSensitive: false),
		];

		for (final pattern in patterns) {
			final match = pattern.firstMatch(text);
			if (match != null) {
				final parsed = _parseDateToken(match.group(1));
				if (parsed != null) return parsed;
			}
		}

		return _extractFirstDate(text);
	}

	DateTime? _extractDueDate(String text) {
		const dateTokenPattern =
				r'((?:[0-9]{4}[\-/][0-9]{1,2}[\-/][0-9]{1,2})|(?:[0-9]{1,2}[\-/][0-9]{1,2}[\-/][0-9]{2,4}))';
		final patterns = [
			RegExp(
				'(?:due\\s*date|due|payment\\s*due)\\s*[:\\-]?\\s*$dateTokenPattern',
				caseSensitive: false,
			),
			RegExp(r'(?:due\s*date|due|payment\s*due)\s*[:\-]?\s*([A-Za-z]{3,9}\s+[0-9]{1,2},?\s+[0-9]{4})', caseSensitive: false),
		];

		for (final pattern in patterns) {
			final match = pattern.firstMatch(text);
			if (match != null) {
				final parsed = _parseDateToken(match.group(1));
				if (parsed != null) return parsed;
			}
		}
		return null;
	}

	DateTime? _extractFirstDate(String text) {
		final generic = RegExp(
			r'((?:[0-9]{4}[\-/][0-9]{1,2}[\-/][0-9]{1,2})|(?:[0-9]{1,2}[\-/][0-9]{1,2}[\-/][0-9]{2,4}))',
		);
		final match = generic.firstMatch(text);
		if (match == null) return null;
		return _parseDateToken(match.group(1));
	}

	DateTime? _parseDateToken(String? token) {
		if (token == null || token.trim().isEmpty) return null;
		final value = token.trim();

		final formats = [
			'yyyy-MM-dd',
			'dd-MM-yyyy',
			'MM-dd-yyyy',
			'dd/MM/yyyy',
			'MM/dd/yyyy',
			'd/M/yyyy',
			'd-M-yyyy',
			'd MMM yyyy',
			'd MMMM yyyy',
			'MMM d, yyyy',
			'MMMM d, yyyy',
			'dd/MM/yy',
			'MM/dd/yy',
		];

		for (final format in formats) {
			try {
				return DateFormat(format).parseStrict(value);
			} catch (_) {
				// Continue trying alternative date formats.
			}
		}

		return null;
	}

	String? _extractContactName(String text) {
		final patterns = [
			RegExp(r'(?:bill\s*to|customer|client|to)\s*[:\-]?\s*([^\n\r]{3,60})', caseSensitive: false),
		];

		for (final pattern in patterns) {
			final match = pattern.firstMatch(text);
			if (match != null) {
				final name = match.group(1)?.trim();
				if (name != null && name.length >= 3) {
					return name;
				}
			}
		}

		return null;
	}

	String? _extractCurrencyCode(String text) {
		const supported = {'USD', 'EUR', 'GBP', 'MAD', 'CAD', 'AUD'};
		final codeRegex = RegExp(r'\b([A-Z]{3})\b');
		for (final match in codeRegex.allMatches(text)) {
			final code = match.group(1);
			if (code != null && supported.contains(code)) {
				return code;
			}
		}

		if (text.contains('\$')) return 'USD';
		if (text.contains('€')) return 'EUR';
		if (text.contains('£')) return 'GBP';

		return null;
	}

	String? _extractStatus(String lowerText) {
		if (lowerText.contains('paid')) return 'paid';
		if (lowerText.contains('partial')) return 'partial';
		if (lowerText.contains('sent')) return 'sent';
		if (lowerText.contains('cancelled') || lowerText.contains('canceled')) return 'cancelled';
		if (lowerText.contains('received')) return 'received';
		return null;
	}
}
