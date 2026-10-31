---
name: zambo-init
description: Wire Zambo into a project permanently so every AI session in it uses Zambo by default. Use when the user says "init Zambo", "set up Zambo in this project", "wire Zambo into this repo", "add Zambo to this project", "make Zambo the default here", or wants Zambo to be a project's standing memory, receipt, and handover layer instead of a one-off connection they have to remember.
---

# Zambo init: make Zambo the default for a project

Zambo is the verifiable work layer for AI: 153 tools behind one MCP endpoint, memory that follows the user across AIs, a verifiable receipt for every job, and HANDOVER for carrying work between AIs.

A one-off connection dies with the chat. This skill wires Zambo into the project itself, so it comes back on its own: the MCP server lands in the project's `.mcp.json`, and a short working loop lands in the project's `AGENTS.md`, where every agent reads its instructions. Once a project is wired, every session in it starts from saved memory, checks for a waiting handover, and wraps up with one at the end, without the user asking.

## Run it

The skill ships a script that does both writes safely:

```bash
bash scripts/zambo-init.sh /path/to/project
```

Run it from this skill's folder, or pass no argument to wire the current directory. The script:

- Merges the Zambo server into `.mcp.json` as `{"mcpServers": {"zambo": {"url": "https://zambo.dev/mcp"}}}`, preserving any servers already configured.
- Adds a managed block to `AGENTS.md` between `<!-- zambo-init:start -->` and `<!-- zambo-init:end -->` markers: check in first (pick up a waiting handover, recall memory), remember as you go, hand over at the end.
- Saves a one-time backup (`<file>.zambo-bak`) the first time it touches an existing file.
- Is safe to re-run. A second run changes nothing, so it can also repair a block someone edited.

## If you cannot run the script

Do the same two writes by hand:

1. In the project's `.mcp.json`, add `"zambo": {"url": "https://zambo.dev/mcp"}` inside `mcpServers`, keeping what is already there. Create the file with just that entry if it does not exist.
2. Append the block from the script (between the same markers) to the project's `AGENTS.md`, creating the file if needed.

Then read both files back and confirm the entry and the block are present and the JSON parses.

## After wiring

- Tell the user to reconnect or restart their AI client once, so it loads the server from `.mcp.json`. After that it loads on its own.
- Confirm the connection by calling a Zambo tool (for example, recall memory or list handovers) in the new session.
- Optional, for Claude Code projects: [SESSION-END-HOOK.md](SESSION-END-HOOK.md) shows how to add a project hook that prompts the wrap-up automatically when a session is about to stop, so the loop closes even when nobody remembers step 3.

## Costs, stated plainly

- Free every day: 20 calls + 1 wrap-up free every day; picking up in another AI is always free.
- A Day Pass is $0.99 for 24 hours of unlimited use. A Zambo Pass is $29 for 30 days ($290 for a year, $19 for eligible token holders).
- Wiring a project costs nothing and needs no API key or signup.

## Say it straight

- The working loop makes Zambo's memory and handovers the project's default. It does not make any single result correct, and never claim it does.
- A verifiable receipt proves the saved record was not changed after it was saved. It does not prove the work was right.
