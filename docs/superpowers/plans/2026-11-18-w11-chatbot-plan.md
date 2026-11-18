# W11 Chatbot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete Flutter lab 1 and lab 4 with visible chat states, animated replies, retryable errors, accessibility support, evidence documentation, and staged commits.

**Architecture:** Keep the starter app small and use one `main.dart` state machine plus a local `AiClient` abstraction. The mock client reproduces success and HTTP-like failures so the UI follows the same async flow without exposing an API key or requiring an external server.

**Tech Stack:** Flutter/Dart, Material 3, `flutter_test`, `AnimatedList`, `AnimatedSwitcher`, `AnimationController`.

**Spec:** `docs/superpowers/specs/2026-11-18-w11-chatbot-design.md`

## Global Constraints

- Complete 실습 1 TODO 2~5 and 실습 4 오류·재시도.
- Support idle, sending, typing, done, and error behavior in code and UI.
- Use 250ms message insertion, animated typing dots, and `MediaQuery.disableAnimations`.
- Show retryable 401/429/500/timeout errors in the conversation area.
- Keep input usable after errors and prevent duplicate sends.
- Provide `docs/w11.md`, README evidence, and at least two meaningful commits.

## Review Focus

- Empty message submission must do nothing: widget test in Task 1.
- Rapid repeated submission must create one request: widget test in Task 2.
- Retry after an error must reuse the last user message: client/state test in Task 3.
- Reduce Motion must keep final content visible with zero-duration transitions: widget test in Task 3.
- Keyboard/insets and long messages must not overflow: widget test and manual Chrome check in Task 1.

### Task 1: Complete chat UI (실습 1)

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Produces `_ChatPageState` with controller lifecycle, editable messages, empty state, and send callback for later state-machine work.

- [ ] Write failing widget tests for user/AI bubble alignment, empty-state text, and non-empty submission behavior.
- [ ] Run `flutter test` and confirm the starter TODO behavior fails the new expectations.
- [ ] Implement `_Bubble` alignment/decoration, `TextEditingController`, empty-state `Stack`, `TextField` + send button, `SafeArea`, and `_send()` with trimmed input.
- [ ] Dispose the controller and keep `resizeToAvoidBottomInset` enabled.
- [ ] Run `flutter analyze` and `flutter test`.
- [ ] Commit `feat: complete chat ui lab 1`.

### Task 2: Add chat state machine and animated success response

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- `enum ChatFailureKind { unauthorized, rateLimited, server, timeout, network }`
- `class ChatFailure implements Exception { final ChatFailureKind kind; }`
- `abstract class AiClient { Future<String> chat(String prompt); }`
- `MockAiClient.chat` returns a delayed answer or throws based on prompt commands.

- [ ] Write failing tests for immediate user message, typing indicator, disabled input while sending, and 250ms animated bot insertion.
- [ ] Run tests and confirm failure because no async state exists.
- [ ] Add `AiClient`, `MockAiClient`, `_sending`, `_typing`, `AnimatedList`, `ScrollController`, and post-frame scroll-to-bottom behavior.
- [ ] Implement `TypingDots` with 200ms cadence and make animation duration zero when `disableAnimations` is true.
- [ ] Ensure `_send()` blocks duplicate calls, adds the user message first, awaits the client, inserts the bot answer, and resets flags in `finally`.
- [ ] Run `flutter analyze` and `flutter test`.
- [ ] Commit `feat: add chatbot states and animated replies`.

### Task 3: Add errors, retry, backoff, accessibility, and submission evidence

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`
- Modify: `README.md`
- Create: `docs/w11.md`

**Interfaces:**
- `_error` stores the visible error message and `_lastPrompt` stores the retry target.
- `_retry()` resends `_lastPrompt` and clears the visible error only after a new attempt starts.
- `_failureMessage(ChatFailure)` maps 401, 429, 500, timeout, and network failures to Korean user-facing copy.

- [ ] Write failing tests for each error message, retry success, and error recovery that leaves the input enabled.
- [ ] Run tests and confirm failure before error handling is implemented.
- [ ] Implement `AnimatedSwitcher` error bubble with retry button, exponential 1s→2s delay for 429 retries, and safe `mounted` checks.
- [ ] Keep errors in the message area, preserve the last user prompt, and allow a new message after failure.
- [ ] Add README run instructions, scenario commands, checklist, and screenshot/GIF placeholder path; add the five-section `docs/w11.md` portfolio record.
- [ ] Run `flutter analyze`, `flutter test`, and manual success/error/retry/keyboard/Reduce Motion checks.
- [ ] Commit `feat: add error retry and assignment evidence`.

### Task 4: Final verification and handoff

**Files:**
- Inspect: repository history and working tree

- [ ] Run the full test and analyzer commands from a clean working tree.
- [ ] Review `git log --oneline` to verify staged commits and `git diff` to ensure no accidental files are included.
- [ ] Report the local repository path, commit list URL template, remaining GitHub push requirement, and any manual screenshot action.
