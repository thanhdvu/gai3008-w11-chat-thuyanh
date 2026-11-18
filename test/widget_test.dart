import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab1_chat_ui/main.dart';

void main() {
  testWidgets('채팅 UI는 말풍선과 입력창을 보여 준다', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatLabApp());

    // 제목
    expect(find.text('AI Chat — 실습 1·4'), findsOneWidget);

    // 대화 목록과 양쪽 말풍선
    expect(find.byType(AnimatedList), findsOneWidget);
    expect(find.text('오늘 뭐 배워?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('입력한 메시지는 사용자 말풍선으로 추가된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatLabApp());
    await tester.enterText(find.byType(TextField), '새 질문');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('새 질문'), findsOneWidget);
  });

  testWidgets('전송 중에는 타이핑 점이 보이고 AI 답변이 도착한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatLabApp());
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('typing-dots')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('AI 답변: hello'), findsOneWidget);
  });

  testWidgets('401 오류는 말풍선에 남고 다시 시도 버튼이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatLabApp());
    await tester.enterText(find.byType(TextField), '/401');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('키/권한을 확인해 주세요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}
