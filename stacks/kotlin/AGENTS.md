# AGENTS.md — Kotlin (Android default; JVM/KMP noted)

Workflow files: `docs/spec.md` (what the project is), `docs/decisions.md` (decisions made), `PLAN.md` (current plan). Read them before planning or coding.

## Verify (run all before calling any step done)
1. `./gradlew check` — runs unit tests, lint, and ktlint/detekt/spotless if the project configures them.
2. Fast loop while working: `./gradlew testDebugUnitTest` (Android) or `./gradlew test` (JVM/KMP).

Do not run `connectedAndroidTest`, emulators, or release builds unless asked. Avoid `--refresh-dependencies`.
Look at `build.gradle.kts` and `gradle/libs.versions.toml` to see which linters actually exist; do not assume.

## Project-specific (fill in when the project starts)
- Target: TODO (Android / JVM / KMP)
- UI: TODO (Jetpack Compose?)
- DI: TODO (Hilt / Koin / manual)
- Persistence / network: TODO
- minSdk / targetSdk: TODO

## Conventions
- Idiomatic Kotlin: immutable `val`, data classes, sealed interfaces for state and events. No `!!`.
- Coroutines + Flow with structured concurrency. No `GlobalScope`. Inject dispatchers so they can be replaced in tests.
- Architecture: UI -> ViewModel (exposes immutable UI state as `StateFlow`) -> repository -> data source. Keep it as the spec says.
- Compose: stateless composables, hoist state, pass lambdas down, add a `@Preview` for new screens.
- Dependencies only through the version catalog (`libs.versions.toml`). New dependency only if the plan says so.
- Never edit generated code (KSP/KAPT output, `build/`).

## Tests
- JUnit for units; Turbine for Flow if the project uses it; use whatever mocking/fake approach the repo already uses. Prefer fakes.
- Replace `Dispatchers.Main` in ViewModel tests with the project's test rule.

## Lessons (add a rule here every time the agent fails the same way twice)
- (empty)
