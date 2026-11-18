import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab1_chat_ui/main.dart';

void main() {
  testWidgets('capture implemented Flutter chat screen', (tester) async {
    final loader = FontLoader('Roboto')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('C:/Windows/Fonts/malgun.ttf').readAsBytesSync(),
          ),
        ),
      );
    await loader.load();
    await tester.pumpWidget(
      const RepaintBoundary(key: Key('evidence'), child: ChatLabApp()),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField), '안녕하세요');
    // Capture the empty state separately; do not require a running proxy.
    await tester.pumpWidget(
      const RepaintBoundary(
        key: Key('evidence'),
        child: MaterialApp(debugShowCheckedModeBanner: false, home: ChatPage()),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), '안녕하세요');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byKey(const Key('evidence')),
      matchesGoldenFile('../docs/evidence/chat-ui.png'),
    );
    await tester.pumpWidget(const SizedBox());
  }, skip: !File('C:/Windows/Fonts/malgun.ttf').existsSync());
}
