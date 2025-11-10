import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_pdf_assistant/features/chat/presentation/providers/chat_providers.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatStateProvider);

    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('AI PDF Assistant'),
        if (chatState.pdfName != null && chatState.pdfName!.isNotEmpty)
          Text(
            chatState.pdfName!,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: titleWidget,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              ref.read(chatStateProvider.notifier).pickAndProcessPdf();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('Upload a PDF to start chatting'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Отправка сообщения будет реализована позже
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


