import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

/// The app knows only the proxy URL. No provider key belongs in Flutter.
class ProxyAiClient implements AiClient {
  ProxyAiClient({
    http.Client? transport,
    this.base = const String.fromEnvironment(
      'CHAT_BASE',
      defaultValue: 'http://localhost:8787',
    ),
    this.timeout = const Duration(seconds: 30),
  }) : transport = transport ?? http.Client();
  final http.Client transport;
  final String base;
  final Duration timeout;
  @override
  Future<String> chat(String prompt) async {
    try {
      final response = await transport
          .post(
            Uri.parse('$base/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': prompt}),
          )
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw ChatFailure(switch (response.statusCode) {
          401 => ChatFailureKind.unauthorized,
          429 => ChatFailureKind.rateLimited,
          _ => ChatFailureKind.server,
        });
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['answer'] as String;
    } on TimeoutException {
      throw const ChatFailure(ChatFailureKind.timeout);
    } on ChatFailure {
      rethrow;
    } catch (_) {
      throw const ChatFailure(ChatFailureKind.network);
    }
  }
}
