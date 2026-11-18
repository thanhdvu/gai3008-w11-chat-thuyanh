# 11주차 챗봇 과제 설계

## 의도

수업에서 제공한 Flutter starter를 바탕으로 실습 1(채팅 UI)과 실습 4(오류·재시도)를 개인 저장소에서 완성한다. 제출물은 화면 동작, 상태 변화, 접근성, 단계별 커밋을 확인할 수 있어야 한다.

## 목표

- idle 상태에서 빈 상태 문구, 사용자/AI 말풍선, 입력창을 보여 준다.
- sending/typing 동안 입력을 잠그고 타이핑 점 3개를 표시한다.
- 응답을 250ms 삽입 애니메이션으로 추가하고 새 메시지로 스크롤한다.
- 401/429/500/timeout을 오류 말풍선으로 표시하고 마지막 사용자 메시지를 재시도한다.
- `MediaQuery.disableAnimations`가 켜지면 움직임만 끄고 정보는 즉시 보여 준다.
- 키보드가 입력창을 가리지 않도록 SafeArea와 Scaffold 리사이즈를 사용한다.
- README와 `docs/w11.md`에 실행·검증 증거를 기록한다.

## 제외 범위

실제 AI API 키와 외부 서버 배포는 제외한다. 대신 로컬 mock client가 성공·오류 시나리오를 재현한다. 이를 통해 수업에서 요구한 상태와 오류 흐름을 재현 가능하게 검증한다.

## 구현 방식

### 선택지

1. 외부 proxy 서버까지 구성: 수업 구조와 가장 가깝지만 별도 서버·환경 설정이 필요하다.
2. Flutter 내부 mock client: 키 없이 401/429/500/timeout을 반복 재현할 수 있고 제출·시연이 안정적이다.
3. UI만 작성하고 오류는 정적 화면으로 제출: 구현량은 작지만 실습 4의 재시도 동작을 증명하지 못한다.

### 결정

2번을 선택한다. 앱 경계에는 `AiClient.chat()`을 두고, mock client가 입력 명령으로 성공 또는 특정 오류를 반환한다. UI는 실제 proxy를 호출하는 코드와 같은 `Future` 흐름으로 `sending`, `typing`, `done`, `error`를 관리한다.

## 단계별 커밋

1. `feat: complete chat ui lab 1` — 말풍선, 입력 전송, 빈 상태, 키보드 대응.
2. `feat: add chatbot states errors and retry` — typing dots, AnimatedList 삽입, 오류 문구, retry, backoff, Reduce Motion, 테스트·문서.

## 검증

- `flutter analyze`
- `flutter test`
- Chrome 또는 Android 에뮬레이터에서 성공 응답, 401, 429, 500, timeout, retry, 키보드, Reduce Motion 확인
- README에 개선된 화면 스크린샷 또는 GIF 위치를 남긴다.
