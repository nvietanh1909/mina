import 'package:mina/model/chat_message.dart';
import 'package:mina/services/api_service.dart';

class ChatbotService {
  final AuthService _authService = AuthService();

  Future<ChatMessage> sendMessage(String message, String userId) async {
    try {
      final response = await _authService.getAuthenticatedData(
        '/api/chatbot/chat',
        method: 'POST',
        body: {
          'message': message,
          'userId': userId,
        },
      );

      return ChatMessage(
        message: response['data']['message'],
        response: response['data']['response'],
        createdAt: DateTime.now(),
        isUser: false,
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      final response = await _authService.getAuthenticatedData(
        '/api/chatbot/history/$userId',
      );

      return (response['data'] as List)
          .map((item) => ChatMessage.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}