import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_pdf_assistant/features/chat/presentation/providers/chat_providers.dart';
import 'package:ai_pdf_assistant/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

final _chatInputControllerProvider =
    riverpod.Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatStateProvider);
    final controller = ref.watch(_chatInputControllerProvider);

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
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(
                    child: Text('Upload a PDF to start chatting'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatState.messages[index];
                      return ChatMessageBubble(message: msg);
                    },
                  ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
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
                    final text = controller.text;
                    ref
                        .read(chatStateProvider.notifier)
                        .askQuestion(text)
                        .then((_) => controller.clear());
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


