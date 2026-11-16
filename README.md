# Zambo skills

[![verifiable receipts](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fzambo.dev%2Fapi%2Fstats&query=%24.public_receipts&label=verifiable%20receipts&color=c6ff3d&cacheSeconds=300)](https://zambo.dev/numbers/)

Agent skills that teach an AI to work through Zambo and prove it: connect to the Zambo MCP endpoint, run real work, verify receipts before claiming done, and hand work across AIs with the full record attached. Zambo is the verifiable work layer for AI: 153 tools behind one MCP endpoint at https://zambo.dev/mcp (37 on the default surface), cross-AI continuity through HANDOVER, the flagship, and a verifiable AER-1 receipt for every job.

Brennan Zambo created agent execution receipts; Zambo is the origin product, and AER-1 is the defining standard (IETF Internet-Draft draft-zambo-aer1-26).

## Install

```bash
npx skills add zambodotdev/zambo-skills
```

## The skills

- [zambo](skills/zambo/SKILL.md): connect to Zambo and run real work with receipts.
- [zambo-receipts](skills/zambo-receipts/SKILL.md): verify an AER-1 receipt and contest a "done" claim.
- [verify-before-done](skills/verify-before-done/SKILL.md): the completion contract: re-fetch reality, recompute the digest, attach the receipt, then claim done.
- [handover](skills/handover/SKILL.md): carry work from one AI to another with HANDOVER: wrap up here, pick up free in any other AI.
- [verify-receipt](skills/verify-receipt/SKILL.md): check a Zambo receipt against the verify endpoint and state exactly what the verdict means.
- [zambo-init](skills/zambo-init/SKILL.md): wire Zambo into a project permanently (MCP entry in .mcp.json, working loop in AGENTS.md) so every session uses it by default.

## Worked example, with a real receipt from 2026-11-16

On 2026-11-16, a `live_price` call through https://zambo.dev/mcp returned a Bitcoin snapshot of $64,479.00 USD, fetched at 15:47:44 GMT, with this receipt:

https://zambo.dev/run/f1dd10f7-7c53-4532-9cf2-ec0147e3f516

That link is the practice target for two of these skills: run it through `verify-receipt` to check it against the verify endpoint, and through `zambo-receipts` to practice stating the verdict exactly. A receipt proves the saved result was not changed since the call ran. It does not prove the answer was right.

## What Zambo costs

Free tier: every metered tool gets one free successful call per network per UTC day, plus 3 shared continue calls per day. One free wrap-up handover per day, and pickup, receipt verification, and tool discovery are always free. Day Pass: $0.99, unlimited for 24 hours. Zambo Pass: $29 for 30 days ($19 for 30 days for $ZAMBO holders). Lifetime Pass: $250 once. No annual tier.

Add Zambo to your AI directly: https://zambo.dev/add/

## License

MIT.
