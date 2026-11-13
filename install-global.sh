#!/usr/bin/env bash
# Installs the global agents and commands into ~/.config/opencode,
# filling in the models from a profile in profiles/<name>.env.
#
#   ./install-global.sh              # profile "mixed-free" (default)
#   ./install-global.sh gemini-only  # switch profile = rotate when a free tier runs out
#   ./install-global.sh --list       # list profiles
#
# Override the target dir with OPENCODE_CONFIG_DIR=/some/dir ./install-global.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

if [[ "${1:-}" == "--list" ]]; then
  active="$(cat "$ROOT/.active-profile" 2>/dev/null || echo none)"
  for f in "$ROOT"/profiles/*.env; do
    n="$(basename "$f" .env)"
    [[ "$n" == "$active" ]] && echo "* $n (active)" || echo "  $n"
  done
  exit 0
fi

PROFILE="${1:-mixed-free}"
PFILE="$ROOT/profiles/$PROFILE.env"
if [[ ! -f "$PFILE" ]]; then
  echo "Unknown profile: $PROFILE" >&2
  echo "Available: $(cd "$ROOT/profiles" && ls ./*.env | sed 's|./||;s|\.env||' | tr '\n' ' ')" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$PFILE"
for v in PLAN_MODEL BUILD_MODEL REVIEW_MODEL TEST_MODEL; do
  val="${!v:-}"
  if [[ -z "$val" || "$val" == *TODO* ]]; then
    echo "$v is empty or TODO in $PFILE" >&2
    exit 1
  fi
done

mkdir -p "$CONF/agents" "$CONF/commands"

render() {
  local src="$1" dst="$2" tmp
  tmp="$(mktemp)"
  sed -e "s|@@PLAN_MODEL@@|$PLAN_MODEL|g" \
      -e "s|@@BUILD_MODEL@@|$BUILD_MODEL|g" \
      -e "s|@@REVIEW_MODEL@@|$REVIEW_MODEL|g" \
      -e "s|@@TEST_MODEL@@|$TEST_MODEL|g" \
      "$src" > "$tmp"
  if [[ -f "$dst" ]] && ! cmp -s "$tmp" "$dst"; then
    cp "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "  (backed up previous $(basename "$dst"))"
  fi
  mv "$tmp" "$dst"
  chmod 644 "$dst"
  echo "  -> $dst"
}

echo "Installing profile '$PROFILE' into $CONF"
for f in "$ROOT"/global/agents/*.md;   do render "$f" "$CONF/agents/$(basename "$f")";   done
for f in "$ROOT"/global/commands/*.md; do render "$f" "$CONF/commands/$(basename "$f")"; done
echo "$PROFILE" > "$ROOT/.active-profile"

echo
echo "Done. plan=$PLAN_MODEL build=$BUILD_MODEL review=$REVIEW_MODEL test=$TEST_MODEL"
echo "Your opencode.json / opencode.jsonc were not touched."
