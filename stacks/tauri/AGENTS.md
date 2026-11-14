# AGENTS.md — Tauri (v2 assumed) + web frontend

Project spec: `docs/spec.md` (what the project is). Read it before planning or coding.

## Verify (run all, in order, before calling any step done)
Rust (from `src-tauri/`):
1. `cargo fmt --check`
2. `cargo clippy --all-targets -- -D warnings`
3. `cargo test`

Frontend (repo root; package manager per lockfile, examples with pnpm):
4. `pnpm exec tsc --noEmit`
5. `pnpm lint`
6. `pnpm vitest run`

Run only the half that the step touched, but run both if the step changes the IPC boundary (commands, events, shared types).
Do not run `tauri dev` or `tauri build` (long-running / slow). Ask the user.
Check `package.json` scripts and `Cargo.toml` before assuming a tool exists.

## Project-specific (fill in when the project starts)
- Frontend framework: TODO
- Tauri plugins in use: TODO
- State/persistence: TODO
- Target OS: TODO

## Conventions
- Rust side: `#[tauri::command]` functions stay thin. Business logic lives in plain modules that can be tested without Tauri.
- Errors: a project error type (e.g. `thiserror`) that implements `Serialize`; commands return `Result<T, E>`. No `unwrap()` / `expect()` outside tests.
- Shared state through `tauri::State` (with `Mutex`/`RwLock` as needed). Async commands use the runtime already in the project.
- IPC contract: every command and event has a matching TypeScript type. Change both sides in the same step.
- Security: capabilities/permissions in `src-tauri/capabilities/` stay minimal. Never grant broad fs or shell scopes. The frontend reaches the OS only through commands or scoped plugins.
- Frontend rules: follow the web-ts conventions (strict TS, validate input, no `any`).
- No new crates or npm packages unless the plan says so.

## Tests
- Rust: unit tests next to the code (`#[cfg(test)]`), integration tests in `src-tauri/tests/`.
- Frontend: Vitest. Mock the IPC layer at one boundary (a thin wrapper around `invoke`), not everywhere.

## Lessons (add a rule here every time the agent fails the same way twice)
- (empty)
