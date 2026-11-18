# 11주차 과제 — AI Chat (GAI3008-01)

실습 1 채팅 UI와 실습 4 오류·재시도를 개인 구현한 저장소입니다.

## 실행

```bash
flutter pub get
flutter run -d chrome
```

외부 API key 없이 실행됩니다. 테스트용 입력은 `/401`, `/429`, `/500`, `/timeout`, `/network`이며, 일반 문장은 mock AI가 응답합니다.

## 구현 체크리스트

- [x] 사용자/AI 말풍선 좌우 정렬
- [x] 빈 상태 `무엇이든 물어보세요`
- [x] 입력창·전송 버튼·키보드 대응
- [x] sending/typing/done/error 흐름
- [x] 타이핑 점 3개와 `AnimatedList` 250ms 삽입
- [x] 401/429/500/timeout 오류와 다시 시도
- [x] 429 retry 지수 backoff 1초 → 2초
- [x] Reduce Motion에서 애니메이션만 비활성화

## 화면 증거

Flutter 위젯을 실제 렌더링한 화면입니다 (자동 캡처).

![채팅 UI](docs/evidence/chat-ui.png)

## 단계별 커밋

| 단계 | 내용 | 커밋 |
|---|---|---|
| 1 | 채팅 UI 완성 | `feat: complete chat ui lab 1` |
| 2 | 상태·애니메이션·오류·재시도 | `feat: add chatbot states and animated replies` |
| 3 | 제출 기록·검증 | `feat: add error retry and assignment evidence` |

## 제출

- 저장소 URL
- 커밋 목록 URL: `/commits/main/`
- `docs/w11.md` 5칸 기록
- 개선된 화면 캡처 또는 GIF
