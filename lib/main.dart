import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const ChatLabApp());

class ChatLabApp extends StatelessWidget {
  const ChatLabApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AI Chat — 실습 1·4',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6FE4)),
          useMaterial3: true,
        ),
        home: const ChatPage(),
      );
}

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser, this.isError = false});
  final String text;
  final bool isUser;
  final bool isError;
}

enum ChatFailureKind { unauthorized, rateLimited, server, timeout, network }

class ChatFailure implements Exception {
  const ChatFailure(this.kind);
  final ChatFailureKind kind;
}

abstract class AiClient {
  Future<String> chat(String prompt);
}

class MockAiClient implements AiClient {
  const MockAiClient();

  @override
  Future<String> chat(String prompt) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    switch (prompt.trim().toLowerCase()) {
      case '/401':
        throw const ChatFailure(ChatFailureKind.unauthorized);
      case '/429':
        throw const ChatFailure(ChatFailureKind.rateLimited);
      case '/500':
        throw const ChatFailure(ChatFailureKind.server);
      case '/timeout':
        throw const ChatFailure(ChatFailureKind.timeout);
      case '/network':
        throw const ChatFailure(ChatFailureKind.network);
      default:
        return 'AI 답변: $prompt';
    }
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.client = const MockAiClient()});
  final AiClient client;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _listKey = GlobalKey<AnimatedListState>();
  final List<ChatMessage> _messages = [
    const ChatMessage(text: '오늘 뭐 배워?', isUser: true),
    const ChatMessage(text: 'AI 챗봇에 움직이는 응답을 붙입니다.', isUser: false),
    const ChatMessage(text: '타이핑 점은 왜 필요해요?', isUser: true),
    const ChatMessage(text: '응답이 1초를 넘으면 앱이 멈춘 것처럼 보이기 때문입니다.', isUser: false),
  ];
  late final AnimationController _dotsController;
  bool _sending = false;
  bool _typing = false;
  String? _error;
  String? _lastPrompt;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('AI Chat — 실습 1·4')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  AnimatedList(
                    key: _listKey,
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    initialItemCount: _messages.length,
                    itemBuilder: (context, index, animation) {
                      final message = _messages[_messages.length - 1 - index];
                      final duration = reduce
                          ? Duration.zero
                          : const Duration(milliseconds: 250);
                      return SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topCenter,
                        child: _Bubble(message: message, duration: duration),
                      );
                    },
                  ),
                  if (_messages.isEmpty && !_typing)
                    const Center(child: Text('무엇이든 물어보세요')),
                  if (_typing)
                    Positioned(
                      left: 12,
                      bottom: 8,
                      child: _TypingDots(
                        key: const Key('typing-dots'),
                        controller: _dotsController,
                        reduceMotion: reduce,
                      ),
                    ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
              child: _error == null
                  ? const SizedBox.shrink()
                  : _ErrorBubble(message: _error!, onRetry: _retry),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_sending,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요 (/401, /429, /500, /timeout 테스트)',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: '전송',
                    icon: const Icon(Icons.send),
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send({String? prompt, bool isRetry = false}) async {
    if (_sending) return;
    final text = (prompt ?? _controller.text).trim();
    if (text.isEmpty) return;
    _lastPrompt = text;
    setState(() {
      _error = null;
      _sending = true;
      _typing = true;
      if (!isRetry) {
        _messages.add(ChatMessage(text: text, isUser: true));
        _controller.clear();
      }
    });
    if (!isRetry) {
      _listKey.currentState?.insertItem(_messages.length - 1);
      _toBottom();
    }
    try {
      if (isRetry && text == '/429') {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      final answer = await widget.client.chat(text);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: answer, isUser: false));
        _typing = false;
      });
      _listKey.currentState?.insertItem(_messages.length - 1);
      _toBottom();
    } on ChatFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = _failureMessage(failure);
        _typing = false;
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _retry() => _send(prompt: _lastPrompt, isRetry: true);

  String _failureMessage(ChatFailure failure) => switch (failure.kind) {
        ChatFailureKind.unauthorized => '키/권한을 확인해 주세요',
        ChatFailureKind.rateLimited => '잠시 후 다시 시도해 주세요',
        ChatFailureKind.server => '응답을 받지 못했습니다',
        ChatFailureKind.timeout => '네트워크를 확인해 주세요',
        ChatFailureKind.network => '네트워크를 확인해 주세요',
      };

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(0);
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _dotsController.dispose();
    super.dispose();
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.duration});
  final ChatMessage message;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: message.isError
              ? colors.errorContainer
              : message.isUser
                  ? colors.primaryContainer
                  : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text),
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots({super.key, required this.controller, required this.reduceMotion});
  final Animation<double> controller;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) return const Text('AI가 답변을 준비하고 있습니다…');
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final active = (controller.value * 3).floor() % 3;
        return Row(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Text(
                '●',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: index <= active ? 1 : .25),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  const _ErrorBubble({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(child: Text(message)),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      );
}
