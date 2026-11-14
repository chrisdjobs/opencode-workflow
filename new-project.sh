#!/usr/bin/env bash
# Usage: ./new-project.sh <flutter|web-ts|kotlin|tauri> [target-dir]
# Copies the stack AGENTS.md and the spec template into the project.
# Never overwrites a file that already exists.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK="${1:-}"
TARGET="${2:-.}"

if [[ -z "$STACK" || ! -f "$ROOT/stacks/$STACK/AGENTS.md" ]]; then
  echo "Usage: $0 <stack> [target-dir]"
  echo "Available stacks: $(ls "$ROOT/stacks" | tr '\n' ' ')"
  exit 1
fi

mkdir -p "$TARGET/docs"

copy_safe() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    echo "  skip (exists): $dst"
  else
    cp "$src" "$dst"
    echo "  created: $dst"
  fi
}

copy_safe "$ROOT/stacks/$STACK/AGENTS.md" "$TARGET/AGENTS.md"
copy_safe "$ROOT/templates/spec.md"       "$TARGET/docs/spec.md"

cat <<MSG

Next:
  1. Fill in the "Project-specific" block of $TARGET/AGENTS.md
  2. Write $TARGET/docs/spec.md
  3. git init (the builder commits), then cd $TARGET && opencode
  4. Tab to the planner, say what you want, adjust the plan in chat
  5. Tab to the builder (or /build <constraints>) -> /review <intent> -> /tests <intent>
MSG
