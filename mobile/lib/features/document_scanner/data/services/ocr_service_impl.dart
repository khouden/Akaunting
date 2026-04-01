import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/services/ocr_service.dart';

class OcrServiceImpl implements OcrService {
	@override
	Future<String> extractTextFromImages(List<String> imagePaths) async {
		if (imagePaths.isEmpty) {
			throw Exception('No scanned images were provided.');
		}

		final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
		final buffer = StringBuffer();

		try {
			for (final path in imagePaths) {
				final image = InputImage.fromFilePath(path);
				final result = await recognizer.processImage(image);

				if (result.text.trim().isNotEmpty) {
					if (buffer.isNotEmpty) {
						buffer.writeln();
						buffer.writeln('---PAGE BREAK---');
						buffer.writeln();
					}
					buffer.writeln(result.text.trim());
				}
			}
		} finally {
			await recognizer.close();
		}

		return buffer.toString();
	}
}
