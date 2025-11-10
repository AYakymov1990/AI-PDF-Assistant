import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_pdf_assistant/features/chat/domain/entities/chat_message.dart';
import 'package:ai_pdf_assistant/features/chat/data/datasources/ai_datasource.dart';

@immutable
class ChatState {
  final String? pdfName;
  final String? pdfText;
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatState({
    this.pdfName,
    this.pdfText,
    this.messages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({
    String? pdfName,
    String? pdfText,
    List<ChatMessage>? messages,
    bool? isLoading,
  }) =>
      ChatState(
        pdfName: pdfName ?? this.pdfName,
        pdfText: pdfText ?? this.pdfText,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier() : super(const ChatState());

  final _uuid = const Uuid();

  Future<void> pickAndProcessPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final String name = file.name;

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

      state = state.copyWith(pdfName: name, pdfText: extractedText);
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('pickAndProcessPdf error: $e\n$st');
      }
    }
  }

  Future<void> askQuestion(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: trimmed,
      isFromUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    final contextText = state.pdfText;
    if (contextText == null || contextText.isEmpty) {
      final botMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Please upload a PDF first.',
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
      return;
    }

    try {
      final ai = GeminiAIDataSource();
      final answer = await ai.getResponse(trimmed, contextText);
      final botMessage = ChatMessage(
        id: _uuid.v4(),
        text: answer,
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('askQuestion error: $e\n$st');
      }
      final botMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Error while generating response.',
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
    }
  }
}

final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, ChatState>((ref) {
  return ChatStateNotifier();
});
