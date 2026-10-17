import 'package:flutter/foundation.dart';

/// Conversational message exchanged in an annotation thread between human developers and AI coding agents.
@immutable
class ThreadMessage {
  const ThreadMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  /// Unique message ID.
  final String id;

  /// Author role: "human" or "agent".
  final String role;

  /// Message content.
  final String content;

  /// Creation timestamp.
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ThreadMessage.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['timestamp'];
    final DateTime time;
    if (rawTimestamp is int) {
      time = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else if (rawTimestamp is String) {
      time = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      time = DateTime.now();
    }

    return ThreadMessage(
      id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      role: json['role'] as String? ?? 'human',
      content: json['content'] as String? ?? '',
      timestamp: time,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThreadMessage &&
        other.id == id &&
        other.role == role &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, role, content, timestamp);
}
