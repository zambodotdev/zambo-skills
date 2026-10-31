#!/usr/bin/env bash
# zambo-init.sh: wire Zambo into a project so every AI session uses it by default.
#
# What it does:
#   1. Adds the Zambo MCP server to <project>/.mcp.json (merging with any
#      servers already there, never removing them).
#   2. Adds a managed working-loop block to <project>/AGENTS.md: check in
#      first, remember as you go, hand over at the end.
#
# Safe to re-run: a second run makes no further changes. The first time it
# touches an existing file it saves a one-time backup next to it
# (<file>.zambo-bak).
#
# Usage: zambo-init.sh [project-dir]   (default: current directory)
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
MCP_FILE="$PROJECT_DIR/.mcp.json"
AGENTS_FILE="$PROJECT_DIR/AGENTS.md"
ZAMBO_URL="https://zambo.dev/mcp"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "zambo-init: project directory not found: $PROJECT_DIR" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "zambo-init: python3 is required to merge the JSON safely. Install python3 and re-run." >&2
  exit 1
fi

backup_once() {
  local f="$1"
  if [ -f "$f" ] && [ ! -f "$f.zambo-bak" ]; then
    cp "$f" "$f.zambo-bak"
    echo "zambo-init: backed up $f to $f.zambo-bak"
  fi
}

# --- .mcp.json -------------------------------------------------------------
backup_once "$MCP_FILE"
python3 - "$MCP_FILE" "$ZAMBO_URL" <<'PYEOF'
import json, os, sys

path, url = sys.argv[1], sys.argv[2]
data = {}
old = None
if os.path.exists(path):
    with open(path) as fh:
        old = fh.read()
    if old.strip():
        try:
            data = json.loads(old)
        except json.JSONDecodeError:
            print("zambo-init: existing .mcp.json is not valid JSON; it was backed up and a fresh file is written", file=sys.stderr)
            data = {}
    if not isinstance(data, dict):
        data = {}
servers = data.get("mcpServers")
if not isinstance(servers, dict):
    servers = {}
    data["mcpServers"] = servers
servers["zambo"] = {"url": url}
new = json.dumps(data, indent=2) + "\n"
if new != old:
    with open(path, "w") as fh:
        fh.write(new)
    print(f"zambo-init: {path} updated, zambo MCP server set to {url}")
else:
    print(f"zambo-init: {path} already up to date")
PYEOF

# --- AGENTS.md managed block ------------------------------------------------
backup_once "$AGENTS_FILE"
python3 - "$AGENTS_FILE" <<'PYEOF'
import os, sys

path = sys.argv[1]
start = "<!-- zambo-init:start -->"
end = "<!-- zambo-init:end -->"
block = """<!-- zambo-init:start -->
## Zambo: check in, remember, hand over

This project is wired to Zambo, the verifiable work layer for AI, through the MCP server in `.mcp.json` (https://zambo.dev/mcp). Every AI that works in this project shares the same Zambo memory, gets a verifiable receipt for every job, and can hand work to any other AI with HANDOVER.

Work this loop in every session:

1. **Check in first.** Before starting new work, ask Zambo what is already here. Call `handover_list` to see whether a handover is waiting, and recall this project's saved memory. If a handover is waiting, pick it up with `handover_accept` and continue from it.
2. **Remember as you go.** Save durable facts, decisions, file locations, and results to Zambo memory during the session, not at the end. What is saved here is what the next session, in any AI, starts from.
3. **Hand over at the end.** Before the session ends, or before switching to another AI, call `handover` to wrap up: what was done, what is left, and where things stand. Give the user the handover link.

Costs: 20 calls + 1 wrap-up free every day; picking up in another AI is always free. A Day Pass is $0.99 for 24 hours of unlimited use.

Say it straight: a verifiable receipt proves the saved record was not changed after it was saved. It never proves the work itself was correct.
<!-- zambo-init:end -->"""

existing = ""
if os.path.exists(path):
    with open(path) as fh:
        existing = fh.read()

if start in existing and end in existing:
    head, rest = existing.split(start, 1)
    _, tail = rest.split(end, 1)
    new = head + block + tail
else:
    base = existing
    if base and not base.endswith("\n"):
        base += "\n"
    new = base + ("\n" if base else "") + block + "\n"

if new != existing:
    with open(path, "w") as fh:
        fh.write(new)
    print(f"zambo-init: {path} updated, Zambo working loop installed (managed block)")
else:
    print(f"zambo-init: {path} already up to date")
PYEOF

echo "zambo-init: done. Reconnect or restart your AI client so it loads the Zambo MCP server."
