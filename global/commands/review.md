---
description: Clean-context review of the changes. Argument = what was requested (and optional scope)
agent: review
subagent: true
subtask: true
---

Review the changes in this repository.

What was requested, and any scope or focus: "$ARGUMENTS"

If that is empty, infer the intent from git log and docs/spec.md and state your assumption. Default scope: uncommitted changes plus the commits made for this work.
