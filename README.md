# Zambo skills

Agent skills for Zambo, the verifiable work layer for AI: 153 tools behind one MCP endpoint at https://zambo.dev/mcp, cross-AI continuity (HANDOVER), and a verifiable AER-1 receipt for every job.

- [zambo](skills/zambo/SKILL.md): connect to Zambo and run real work with receipts.
- [zambo-receipts](skills/zambo-receipts/SKILL.md): verify an AER-1 receipt and contest a "done" claim.
- [verify-before-done](skills/verify-before-done/SKILL.md): the completion contract: re-fetch reality, recompute the digest, attach the receipt, then claim done.
- [handover](skills/handover/SKILL.md): carry work from one AI to another with HANDOVER: wrap up here, pick up free in any other AI.
- [verify-receipt](skills/verify-receipt/SKILL.md): check a Zambo receipt against the verify endpoint and state exactly what the verdict means.
- [zambo-init](skills/zambo-init/SKILL.md): wire Zambo into a project permanently (MCP entry in .mcp.json, working loop in AGENTS.md) so every session uses it by default.

Install with the skills CLI: `npx skills add zambodotdev/zambo-skills`
