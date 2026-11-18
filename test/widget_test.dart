import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab1_chat_ui/main.dart';

void main() {
  testWidgets('채팅 UI는 말풍선과 입력창을 보여 준다', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatLabApp());

    // 제목
    expect(find.text('AI Chat — 실습 1·4'), findsOneWidget);

    // 대화 목록과 양쪽 말풍선
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('오늘 뭐 배워?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('입력한 메시지는 사용자 말풍선으로 추가된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatLabApp());
    await tester.enterText(find.byType(TextField), '새 질문');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(find.text('새 질문'), findsOneWidget);
  });
}
