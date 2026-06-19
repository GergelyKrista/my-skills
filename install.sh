#!/usr/bin/env bash
# Install every skill in this repo into Claude Code's global skills directory.
# Usage:  ./install.sh            (installs all skills)
#         ./install.sh <name>     (installs one skill folder)
set -euo pipefail

DEST="${HOME}/.claude/skills"
mkdir -p "$DEST"

install_one() {
  local d="$1"
  local name="${d%/}"
  if [ ! -f "$d/SKILL.md" ]; then
    echo "skip: $name (no SKILL.md)"; return
  fi
  rm -rf "${DEST:?}/$name"
  cp -r "$d" "$DEST/$name"
  echo "installed: $name -> $DEST/$name"
}

if [ "${1:-}" != "" ]; then
  install_one "${1%/}/"
else
  for d in */ ; do
    install_one "$d"
  done
fi

echo "Done. Restart Claude Code to activate the skill(s)."
