# ai-workflow

A small, reusable setup for working with AI in opencode: one set of role agents (global),
one short `AGENTS.md` per tech stack, one spec per project. No mega-prompt.

## Layout

```
ai-workflow/
├── profiles/            which model plays which role (rotate when a free tier runs out)
├── global/
│   ├── agents/          plan, build, review, test   -> ~/.config/opencode/agents/
│   └── commands/        /plan /build /review /tests -> ~/.config/opencode/commands/
├── stacks/              flutter, web-ts, kotlin, tauri: one AGENTS.md each
├── templates/           docs/spec.md and docs/decisions.md for new projects
├── install-global.sh    installs global/ with a profile's models filled in
└── new-project.sh       copies a stack + docs templates into a project
```

Everything here is opencode config.

## Three layers, three moments

| Layer | Where it ends up | When you do it |
|---|---|---|
| Global agents + commands | `~/.config/opencode/{agents,commands}/` | Once, before any project (and again when you switch profile) |
| Stack rules (`AGENTS.md`) | Project root | When you create a project: `./new-project.sh flutter ~/code/my-app` |
| Spec + decisions | `docs/spec.md`, `docs/decisions.md` in the project | You write the spec at the start of the project |

opencode loads the project's `AGENTS.md` by itself when you start it in that folder. The agents know where to find
the verify commands because their prompts say "run the Verify section of AGENTS.md".

## Setup

```bash
chmod +x *.sh
./install-global.sh            # default profile: mixed-free
./install-global.sh --list     # profiles; * = active
```

Existing agent/command files with different content are backed up as `*.bak.<timestamp>`.
Your `opencode.json` / `opencode.jsonc` are never touched.

Context7 is not installed by these scripts (you did it once globally):
`opencode plugin add @upstash/context7-opencode` then `opencode mcp auth context7`.

## Daily flow

```
cd my-project && opencode
/plan add offline cache for the lessons list     -> plan agent asks, writes PLAN.md
/build                                           -> build agent does the next unchecked step, verifies, commits
/build all                                       -> same, until done or until something fails
/review                                          -> read-only review of the diff against PLAN.md + spec
/tests                                           -> test agent writes and runs tests
```

`Tab` switches between the primary agents (plan, build). `/review` and `/tests` switch to their agents.
Artifacts carry the context: `PLAN.md` is the handoff between agents, not the chat history.

## Rotating models (free tiers)

Models live only in `profiles/*.env`. When a quota runs out:

```bash
./install-global.sh gemini-only     # or zen-only, mixed-free, offline
```

Then restart opencode. To add OpenAI: connect the provider, run `opencode models openai`, copy
`profiles/openai.env.example` to `profiles/openai.env`, fill in the IDs, run `./install-global.sh openai`.

Verify model IDs and free limits yourself; they change often:
`opencode models`, https://aistudio.google.com/rate-limit, https://opencode.ai/docs/zen

## Context7 hardening

The build agent has the mandatory rule "use context7-mcp before writing code that touches library APIs".
If it still skips it, replace that paragraph in `global/agents/build.md` with:

> Before any edit or write that touches library imports, call context7-mcp first.

and re-run `./install-global.sh`.

## When the agent fails

Same failure twice -> add one line to the `## Lessons` section of that stack's `AGENTS.md` (in `stacks/`, so every future
project gets it). Start with Flutter only, use it on 2 real projects, then open the other stacks.

## Check before trusting (5 minutes)

Built against the OpenCode V2 docs (`agents`, `permissions` as a rule list). Run `opencode --version` first.

1. `opencode`, press Tab: `plan` and `build` should show the models from your profile.
2. Ask `plan` to edit a source file: it must refuse. Ask it to write PLAN.md: it must work.
3. Ask `review` to edit a file: it must refuse.
4. Run `/build` on a trivial plan and confirm it calls context7-mcp before touching library code.

If step 2 blocks PLAN.md, the path globs in `global/agents/plan.md` do not match how your version resolves paths; adjust the `resource` values.
