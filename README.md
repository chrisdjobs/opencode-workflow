# ai-workflow

A small, reusable setup for working with AI in opencode: four role agents (global), one short
`AGENTS.md` per tech stack, one spec per project. No mega-prompt, no plan files.

## Layout

```
ai-workflow/
├── profiles/            which model plays which role (rotate when a free tier runs out)
├── global/
│   ├── agents/          plan, build, review, test   -> ~/.config/opencode/agents/
│   └── commands/        /plan /build /review /tests -> ~/.config/opencode/commands/
├── stacks/              flutter, web-ts, kotlin, tauri: one AGENTS.md each
├── templates/           spec.md for new projects
├── install-global.sh    installs global/ with a profile's models filled in
└── new-project.sh       copies a stack AGENTS.md + spec template into a project
```

Everything here is opencode config. VSCodium is only where you open the terminal.

## The flow

1. **Plan, in chat.** `Tab` to the planner (or `/plan <goal>`). Say what you want. It reads the code, asks what it
   needs, and presents a plan in the chat. Ask for changes until you like it. It writes no files.
2. **Build.** `Tab` to the builder and give your constraints, or `/build <constraints>`
   (e.g. `/build no new dependencies, use Riverpod, do not touch auth`). The builder works from the plan in the
   conversation plus your constraints, runs the verify commands, and commits each step. Never pushes.
3. **Review.** `/review <what was asked + constraints>`. Runs in a fresh background session with a different
   model: it does not see the planning/building conversation, so it judges the code, not the builder's reasoning.
4. **Tests.** `/tests <what was asked + what to cover>`. Same fresh context, a third model. It writes tests from
   the intent, the spec and the public interfaces, not from what the implementation happens to do.

The builder ends with a 3-line handoff (what was asked, constraints, what changed). Paste it as the argument of
`/review` and `/tests`, since those sessions do not see the conversation.

## Three layers, three moments

| Layer | Where it ends up | When you do it |
|---|---|---|
| Global agents + commands | `~/.config/opencode/{agents,commands}/` | Once, before any project (again when you switch profile) |
| Stack rules (`AGENTS.md`) | Project root | When you create a project: `./new-project.sh flutter ~/code/my-app` |
| Spec | `docs/spec.md` in the project | You write it at the start of the project |

opencode loads the project's `AGENTS.md` by itself when you start it in that folder. The agents find the verify
commands because their prompts say "run the Verify section of AGENTS.md".

Personal cross-project rules (a few lines, e.g. "ask before adding dependencies") go in
`~/.config/opencode/AGENTS.md`. Check it really loads next to a project `AGENTS.md`: ask an agent to recite its
rules. There is a GitHub issue reporting it being ignored in some versions.

## Setup

```bash
chmod +x *.sh
./install-global.sh            # default profile: mixed-free
./install-global.sh --list     # profiles; * = active
```

Existing agent/command files with different content are backed up as `*.bak.<timestamp>`.
Your `opencode.json` / `opencode.jsonc` are never touched.

Context7 is not installed by these scripts:
`opencode plugin add @upstash/context7-opencode` then `opencode mcp auth context7`.

New project:
```bash
./new-project.sh flutter ~/code/my-app
cd ~/code/my-app && git init     # the builder commits
```
Then fill in the "Project-specific" block of `AGENTS.md` and write `docs/spec.md`.

## Rotating models (free tiers)

Models live only in `profiles/*.env`. When a quota runs out:

```bash
./install-global.sh gemini-only     # or zen-only, mixed-free, offline
```

Then restart opencode. The default `mixed-free` uses three different model families for build, review and tests.
`gemini-only` loses that diversity. To add OpenAI: connect the provider, run `opencode models openai`, copy
`profiles/openai.env.example` to `profiles/openai.env`, fill in the IDs, run `./install-global.sh openai`.

Verify IDs and free limits yourself, they change often:
`opencode models`, https://aistudio.google.com/rate-limit, https://opencode.ai/docs/zen

## Context7 hardening

The builder has the mandatory rule "use context7-mcp before writing code that touches library APIs".
If it still skips it, replace that paragraph in `global/agents/build.md` with:

> Before any edit or write that touches library imports, call context7-mcp first.

and re-run `./install-global.sh`.

## When the agent fails

Same failure twice -> add one line to the `## Lessons` section of that stack's `AGENTS.md` (in `stacks/`, so every
future project gets it). Start with Flutter only, use it on 2 real projects, then open the other stacks.

## Check before trusting (5 minutes)

Built against the OpenCode V2 docs (`agents`, `permissions` as a rule list, `subagent` on commands).
Run `opencode --version` first.

1. `opencode`, press Tab: `plan` and `build` show the models from your profile.
2. Ask `plan` to create or edit any file: it must refuse.
3. Run `/review` after a build: it must run as a background child session, and it should state what intent it
   assumed (it cannot see the conversation). If it does see the conversation, set `subagent: false` in the commands
   and start a new session (`/new`) before reviewing or testing.
4. Ask `review` to edit a file: it must refuse.
5. Give the builder a task that uses a library: it should call context7-mcp before writing code.
6. Background sessions may handle permission prompts differently. If a prompt gets stuck in `/review` or `/tests`,
   switch those commands to `subagent: false`.
