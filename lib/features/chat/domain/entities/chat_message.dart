import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });
}


