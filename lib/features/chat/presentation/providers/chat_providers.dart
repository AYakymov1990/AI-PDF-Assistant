import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

@immutable
class ChatState {
  final String? pdfName;
  const ChatState({this.pdfName});

  ChatState copyWith({String? pdfName}) => ChatState(
        pdfName: pdfName ?? this.pdfName,
      );
}

class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier() : super(const ChatState());

  Future<void> pickAndProcessPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final String? name = file.name;

      // Получаем байты: предпочтительно из памяти, иначе читаем по пути
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) return;

      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final String extractedText = extractor.extractText();
      document.dispose();

      // Временная проверка: выводим текст в консоль
      if (kDebugMode) {
        // ignore: avoid_print
        print('Extracted text (first 500 chars): ${extractedText.substring(0, extractedText.length > 500 ? 500 : extractedText.length)}');
      }

      state = state.copyWith(pdfName: name);
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('pickAndProcessPdf error: $e\n$st');
      }
    }
  }
}

final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, ChatState>((ref) {
  return ChatStateNotifier();
});


