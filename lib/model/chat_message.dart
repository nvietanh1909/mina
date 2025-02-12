class ChatMessage {
  final String message;
  final String response;
  final DateTime createdAt;
  final bool isUser;

  ChatMessage({
    required this.message,
    required this.response,
    required this.createdAt,
    required this.isUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] ?? '',
      response: json['response'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isUser: json['isUser'] ?? true,
    );
  }
}