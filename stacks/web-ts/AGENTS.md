# AGENTS.md — Web (TypeScript: Next.js / Astro)

Workflow files: `docs/spec.md` (what the project is), `docs/decisions.md` (decisions made), `PLAN.md` (current plan). Read them before planning or coding.

## Verify (run all, in order, before calling any step done)
Use the package manager the repo already uses (the lockfile decides). Examples with pnpm:
1. `pnpm exec tsc --noEmit`
2. `pnpm lint`
3. `pnpm vitest run`
Astro projects also: `pnpm astro check`.

Check the `scripts` in `package.json` and use them. If one of these is missing, say so and propose adding it in the plan.
Do not run `dev` (long-running). Run `build` only when the plan or the user asks (slow).

## Project-specific (fill in when the project starts)
- Framework + version: TODO (Next.js App Router / Astro)
- Styling: TODO (Tailwind?)
- Data / backend: TODO
- Auth: TODO
- Deploy target: TODO

## Conventions
- TypeScript strict. No `any`: use `unknown` and narrow. No `@ts-ignore` without a comment saying why.
- Validate all external input (forms, API bodies, env vars) with a schema (zod or the one in the spec). Env vars go through one typed module.
- Next.js (App Router): Server Components by default; `'use client'` only when state, effects or browser APIs are needed. Fetch data on the server. Mutations through Server Actions or route handlers, as the spec says.
- Astro: content collections for content; ship zero JS by default; add `client:*` islands only where interaction is needed.
- Styling follows what the project already uses. Do not mix systems.
- No new dependencies unless the plan says so. Never edit the lockfile by hand.
- Do not leave `console.log` in committed code.

## Tests
- Vitest for units, Testing Library for components. Name: `*.test.ts(x)` next to the file or under `tests/`, matching the repo.
- Prefer fakes over mocks. Test behavior, not implementation.

## Lessons (add a rule here every time the agent fails the same way twice)
- (empty)
