import '../entities/scanned_document_data.dart';

class ScanResult {
	final List<String> imagePaths;
	final ScannedDocumentData extractedData;

	const ScanResult({required this.imagePaths, required this.extractedData});
}

abstract class DocumentScannerRepository {
	Future<ScanResult> scanAndExtract();
}
