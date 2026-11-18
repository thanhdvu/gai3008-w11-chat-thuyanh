import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab1_chat_ui/main.dart';

void main() {
  testWidgets('capture implemented Flutter chat screen', (tester) async {
    final loader = FontLoader('Roboto')..addFont(Future.value(ByteData.sublistView(File('C:/Windows/Fonts/malgun.ttf').readAsBytesSync())));
    await loader.load();
    await tester.pumpWidget(const RepaintBoundary(key: Key('evidence'), child: ChatLabApp()));
    await tester.pump(const Duration(seconds: 1));
    await expectLater(find.byKey(const Key('evidence')), matchesGoldenFile('../docs/evidence/chat-ui.png'));
    await tester.pumpWidget(const SizedBox());
  }, skip: !File('C:/Windows/Fonts/malgun.ttf').existsSync());
}
