# Session-end wrap-up in Claude Code: make step 3 fire on its own

The `zambo-init` working loop asks the agent to hand over at the end of every session. In Claude Code you can make that happen by default with a project hook, so the wrap-up does not depend on anyone remembering step 3.

One constraint shapes the whole recipe, and it is worth stating plainly: a handover is a tool call, so the nudge has to land while the assistant can still act. That is the `Stop` event, which fires each time the assistant is about to finish responding. The `SessionEnd` event sounds like the right hook and is not: by the time it fires the session is already terminating, and the hooks reference is explicit that SessionEnd hooks have no decision control, cannot block termination, and have their JSON output discarded. Use `Stop` for the wrap-up and `SessionEnd` only as a tripwire log.

Mechanics below are from Anthropic's hooks reference (https://docs.claude.com/en/docs/claude-code/hooks), checked 2026-10-31.

## What the reference documents

- Hooks live in settings files under a `hooks` key. `.claude/settings.json` is the project file: single project scope, shareable, and committable, so a team picks the hooks up by cloning. Hook entries merge across settings levels instead of replacing each other.
- Hook handlers can be shell commands, HTTP endpoints, MCP tool calls, LLM prompts, or subagents. The recipes here use command handlers.
- `Stop` fires when the main agent finishes responding. Its input includes `stop_hook_active` (true when the turn is already continuing because of a stop hook) and `last_assistant_message`. A Stop hook can return `hookSpecificOutput.additionalContext` to feed the assistant guidance and keep the conversation going, or return `{"decision": "block", "reason": "..."}` to prevent stopping outright. Blocking is capped: after eight consecutive continuations Claude Code ends the turn anyway.
- `SessionEnd` fires when a session terminates. Its matcher values are the end reasons: `clear`, `resume`, `logout`, `prompt_input_exit`, `other`. It has no decision control, its output is discarded, and its hooks run on a default timeout of 1.5 seconds, which a per-hook `timeout` can raise. The reference files it under side effects: logging and cleanup.
- `${CLAUDE_PROJECT_DIR}` in a hook command expands to the project root, and the same value is exported to the hook process as an environment variable.

## Recipe A (recommended): a Stop hook that prompts the wrap-up

Save as `.claude/hooks/zambo-wrap-up.sh` in the project and make it executable:

```bash
#!/usr/bin/env bash
# Stop hook: prompt the assistant to close the Zambo loop before it stops.
set -euo pipefail
input="$(cat)"
# If a stop hook already continued this turn, let it stop. No loops.
if printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi
cat <<'EOF'
{"hookSpecificOutput": {"additionalContext": "Before you finish: if this session did substantive work and you have not created a Zambo handover for it yet, save any durable facts to Zambo memory, call the handover tool to wrap up, and give the user the handover link. If the session was trivial, or a handover already exists for it, just finish."}}
EOF
```

Register it in the project's `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PROJECT_DIR}/.claude/hooks/zambo-wrap-up.sh\""
          }
        ]
      }
    ]
  }
}
```

The assistant reads the guidance at the moment it is about to stop, judges whether the session earned a wrap-up, and either creates the handover or finishes. Because the hook returns feedback rather than a block, the transcript labels it as hook feedback, not an error.

A stricter variant swaps the script's output for a block:

```json
{"decision": "block", "reason": "Wrap this session up in Zambo first: save durable facts to memory, call the handover tool, and give the user the handover link. Then you may stop."}
```

Use the block only if the softer prompt gets ignored. It fires on every stop, and while the eight-continuation cap and the `stop_hook_active` guard keep it from looping forever, a block on trivial sessions gets old fast. A prompt-type handler is the middle path: the reference supports LLM prompt handlers, which can judge whether the just-finished turn warrants a wrap-up before deciding.

## Recipe B: a SessionEnd tripwire, so silent endings leave a trace

This hook cannot create a handover, and the doc will not pretend otherwise. What it can do is log every session ending, so a human can spot the sessions that ended with no wrap-up and tighten Recipe A.

Save as `.claude/hooks/zambo-session-end.sh` and make it executable:

```bash
#!/usr/bin/env bash
# SessionEnd tripwire: record that a session ended, and why.
# Input on stdin carries the end reason (clear, resume, logout,
# prompt_input_exit, other). Side effect only: SessionEnd hooks have
# no decision control and their output is discarded.
set -euo pipefail
input="$(cat)"
reason="$(printf '%s' "$input" | grep -o '"reason"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
printf '%s session ended (reason: %s)\n' "$(date -u +%FT%TZ)" "${reason:-unknown}" >> "${CLAUDE_PROJECT_DIR:-.}/.claude/zambo-session-ends.log"
```

Register it alongside Recipe A:

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PROJECT_DIR}/.claude/hooks/zambo-session-end.sh\"",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

The `timeout` of 5 (seconds) lifts the hook above the 1.5 second default budget for SessionEnd hooks, which is plenty for appending one line.

## Check-in needs no hook

The other end of the loop is already covered: the `AGENTS.md` block that `zambo-init` installs carries the check-in instruction (look for a waiting handover, recall memory) in the project's standing instructions, read at the start of every session. Claude Code also has a `SessionStart` event (matchers: `startup`, `resume`, `clear`, `compact`, `fork`) if a project ever wants a scripted setup step on top of that, but nothing in the loop requires it.

## Verify it

1. Start Claude Code in the wired project and give it a small real task.
2. When it tries to finish, the Stop hook feedback should appear and, if the task was substantive, the assistant should save memory and produce a handover link before stopping.
3. Quit the session and check `.claude/zambo-session-ends.log` for the tripwire line.
