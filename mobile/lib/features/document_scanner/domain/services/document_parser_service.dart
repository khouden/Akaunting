import '../entities/scanned_document_data.dart';

abstract class DocumentParserService {
	ScannedDocumentData parse(String rawText);
}
