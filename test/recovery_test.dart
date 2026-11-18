import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab1_chat_ui/main.dart';
import 'package:lab1_chat_ui/proxy_client.dart';

class RecoveringClient implements AiClient {
  RecoveringClient(this.kind);
  final ChatFailureKind kind;
  final prompts = <String>[];
  @override
  Future<String> chat(String prompt) async {
    prompts.add(prompt);
    if (prompts.length == 1) throw ChatFailure(kind);
    return '복구 성공';
  }
}

void main() {
  for (final kind in ChatFailureKind.values) {
    testWidgets('$kind retry recovers without duplicating prompt', (
      tester,
    ) async {
      final client = RecoveringClient(kind);
      await tester.pumpWidget(MaterialApp(home: ChatPage(client: client)));
      await tester.enterText(find.byType(TextField), '내 질문');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('다시 시도'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      await tester.tap(find.text('다시 시도'));
      await tester.pump();
      if (kind == ChatFailureKind.rateLimited) {
        await tester.pump(const Duration(milliseconds: 999));
        expect(client.prompts.length, 1);
        await tester.pump(const Duration(milliseconds: 1));
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('복구 성공'), findsOneWidget);
      expect(find.text('내 질문'), findsOneWidget);
      expect(client.prompts, ['내 질문', '내 질문']);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('reduced motion and keyboard inset preserve input', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            viewInsets: EdgeInsets.only(bottom: 250),
          ),
          child: ChatPage(client: const MockAiClient()),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.text('AI가 답변을 준비하고 있습니다…'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    expect(find.text('AI 답변: hello'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final status in [401, 429, 500]) {
    test('proxy maps HTTP $status', () async {
      final client = ProxyAiClient(
        transport: MockClient((_) async => http.Response('{}', status)),
      );
      await expectLater(client.chat('hello'), throwsA(isA<ChatFailure>()));
    });
  }
  test('proxy enforces actual response timeout', () async {
    final client = ProxyAiClient(
      timeout: const Duration(milliseconds: 1),
      transport: MockClient((_) => Completer<http.Response>().future),
    );
    await expectLater(
      client.chat('hello'),
      throwsA(
        isA<ChatFailure>().having(
          (e) => e.kind,
          'kind',
          ChatFailureKind.timeout,
        ),
      ),
    );
  });
}
