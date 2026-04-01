import 'package:equatable/equatable.dart';

import '../../domain/entities/scanned_document_data.dart';

abstract class DocumentScannerState extends Equatable {
	const DocumentScannerState();

	@override
	List<Object?> get props => [];
}

class DocumentScannerInitial extends DocumentScannerState {
	const DocumentScannerInitial();
}

class DocumentScannerInProgress extends DocumentScannerState {
	final String message;

	const DocumentScannerInProgress(this.message);

	@override
	List<Object?> get props => [message];
}

class DocumentScannerSuccess extends DocumentScannerState {
	final ScannedDocumentData data;
	final List<String> imagePaths;

	const DocumentScannerSuccess({required this.data, required this.imagePaths});

	@override
	List<Object?> get props => [data, imagePaths];
}

class DocumentScannerFailure extends DocumentScannerState {
	final String message;

	const DocumentScannerFailure(this.message);

	@override
	List<Object?> get props => [message];
}
