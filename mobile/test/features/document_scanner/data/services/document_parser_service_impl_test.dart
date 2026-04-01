import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/document_scanner/data/services/document_parser_service_impl.dart';

void main() {
  group('DocumentParserServiceImpl', () {
    late DocumentParserServiceImpl parser;

    setUp(() {
      parser = DocumentParserServiceImpl();
    });

    test('extracts key invoice fields from labeled content', () {
      const rawText = '''
Invoice Number: INV-2026-0042
Invoice Date: 2026-03-30
Due Date: 2026-04-14
Bill To: ACME Corp
Currency: USD
Total Due: 1,245.90
Status: paid
''';

      final data = parser.parse(rawText);

      expect(data.documentNumber, 'INV-2026-0042');
      expect(data.amount, closeTo(1245.90, 0.0001));
      expect(data.issueDate?.year, 2026);
      expect(data.issueDate?.month, 3);
      expect(data.issueDate?.day, 30);
      expect(data.dueDate?.year, 2026);
      expect(data.dueDate?.month, 4);
      expect(data.dueDate?.day, 14);
      expect(data.contactName, 'ACME Corp');
      expect(data.currencyCode, 'USD');
      expect(data.status, 'paid');
      expect(data.hasAnyData, true);
      expect(data.overallConfidence, greaterThan(0.6));
    });

    test('infers currency from symbols and parses european amount format', () {
      const rawText = '''
Document No: INV-88
Issued On: 15/03/2026
Payment Due: 30/03/2026
Customer: Continental SARL
Grand Total: € 1.234,50
''';

      final data = parser.parse(rawText);

      expect(data.documentNumber, 'INV-88');
      expect(data.amount, closeTo(1234.50, 0.0001));
      expect(data.currencyCode, 'EUR');
      expect(data.contactName, 'Continental SARL');
      expect(data.issueDate, isNotNull);
      expect(data.dueDate, isNotNull);
    });

    test('returns warnings when extraction is poor or partial', () {
      const rawText = 'blurred';

      final data = parser.parse(rawText);

      expect(data.hasAnyData, false);
      expect(data.warnings, isNotEmpty);
      expect(
        data.warnings.any((w) => w.toLowerCase().contains('could not be detected')),
        true,
      );
    });
  });
}
