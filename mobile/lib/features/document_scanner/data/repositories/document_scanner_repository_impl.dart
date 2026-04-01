import 'dart:io' show Platform;

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/repositories/document_scanner_repository.dart';
import '../../domain/services/document_parser_service.dart';
import '../../domain/services/ocr_service.dart';

class DocumentScannerRepositoryImpl implements DocumentScannerRepository {
	final OcrService _ocrService;
	final DocumentParserService _parserService;

	DocumentScannerRepositoryImpl({
		required OcrService ocrService,
		required DocumentParserService parserService,
	})  : _ocrService = ocrService,
				_parserService = parserService;

	@override
	Future<ScanResult> scanAndExtract() async {
		if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
			throw Exception(
				'Document scanning is supported only on Android and iOS devices.',
			);
		}

		List<String> paths;
		try {
			paths = await CunningDocumentScanner.getPictures() ?? <String>[];
		} on MissingPluginException {
			throw Exception(
				'Scanner plugin is not initialized. Please stop the app and run it again with a full restart.',
			);
		}

		if (paths.isEmpty) {
			throw Exception('Scan cancelled. No document captured.');
		}

		final rawText = await _ocrService.extractTextFromImages(paths);
		if (rawText.trim().isEmpty) {
			throw Exception('No readable text found. Try scanning in better lighting.');
		}

		final parsed = _parserService.parse(rawText);

		return ScanResult(
			imagePaths: paths,
			extractedData: parsed,
		);
	}
}
