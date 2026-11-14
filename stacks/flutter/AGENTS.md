# AGENTS.md — Flutter

Project spec: `docs/spec.md` (what the project is). Read it before planning or coding.

## Verify (run all, in order, before calling any step done)
1. `dart format --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`

If the step touches annotated code (freezed, json_serializable, riverpod_generator, drift...): run `dart run build_runner build --delete-conflicting-outputs` first.
Do not run `flutter run` or release builds (long-running). Ask the user.

## Project-specific (fill in when the project starts)
- State management: TODO
- Routing: TODO
- Backend / data layer: TODO
- Min SDK / platforms: TODO

## Structure (default; edit to match the project)
- `lib/features/<feature>/{data,domain,presentation}`
- `lib/core/` for shared code (theme, networking, utils)
- `test/` mirrors `lib/`

## Conventions
- Null safety always. Prefer `final`, immutable models, `const` constructors.
- No business logic in widgets. Widgets render state and forward events.
- Do not introduce a second state-management approach. Use the one in the spec.
- Add packages with `flutter pub add`, never by hand-editing pubspec, and only if the plan says so.
- Never edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`).
- No `print`; use the project logger.
- After an `await`, check `mounted` before using `BuildContext`. Dispose controllers, streams and focus nodes.
- User-facing strings go through l10n (arb), not hardcoded.

## Tests
- Unit tests for logic, widget tests (`testWidgets`) for UI behavior. Name: `<file>_test.dart`.
- Prefer fakes over mocks. No real network or real time.

## Lessons (add a rule here every time the agent fails the same way twice)
- (empty)
