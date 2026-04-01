import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/document_scanner_repository.dart';
import 'document_scanner_state.dart';

class DocumentScannerCubit extends Cubit<DocumentScannerState> {
	final DocumentScannerRepository _repository;

	DocumentScannerCubit({required DocumentScannerRepository repository})
			: _repository = repository,
				super(const DocumentScannerInitial());

	Future<void> scanDocument() async {
		emit(const DocumentScannerInProgress('Opening camera scanner...'));
		try {
			emit(const DocumentScannerInProgress('Extracting text from document...'));
			final result = await _repository.scanAndExtract();
			emit(
				DocumentScannerSuccess(
					data: result.extractedData,
					imagePaths: result.imagePaths,
				),
			);
		} catch (e) {
			final message = e.toString().replaceFirst('Exception: ', '');
			emit(DocumentScannerFailure(message));
		}
	}

	void reset() {
		emit(const DocumentScannerInitial());
	}
}
