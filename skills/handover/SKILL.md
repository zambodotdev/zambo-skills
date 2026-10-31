---
name: handover
description: Carry work from one AI to another with Zambo HANDOVER. Use when the user wants to switch AIs or models mid-task, continue in a different app (Claude, ChatGPT, Grok, Cursor, Gemini), wrap up a session and resume later elsewhere, hand work to a client or teammate with proof of what was done, or says things like "wrap this up", "hand this over", "pick this up in Claude", "continue this in another AI", or "send this to my client". Pickup in the receiving AI is always free.
---

# Handover with Zambo

Zambo is the verifiable work layer for AI. Its flagship flow, HANDOVER, wraps up the work in this AI into one link that any other AI (or a client) can open to see every step with a verifiable receipt, then pick up and continue. Use this skill whenever work needs to move: across AIs, across sessions, or from you to a person.

## What you need

- The Zambo MCP server connected at https://zambo.dev/mcp. It is free and needs no API key or signup.
- Tools used: `handover` (wrap up / create), `handover_accept` (pick up), `handover_status`, `handover_list`.

If Zambo is not connected, tell the user to add the MCP URL above to their AI client, then continue.

## When to wrap up

- The user is switching AIs or models and does not want to lose the thread.
- A session is ending with unfinished work that will resume elsewhere or later.
- The user is delivering work to a client and wants the client to see proof of each step.
- The user asks you to save state so another agent can take over.

Do not spend a wrap-up on a trivial exchange that is already finished. Each caller gets one free wrap-up per day (see Costs).

## The flow

1. **Save what matters first.** If key facts live only in this conversation, store them with Zambo's memory tools before wrapping, so the receiving AI can recall them verbatim.
2. **Call `handover`** to wrap up the session. It returns a handover id and a link of the form https://zambo.dev/handover/<id>.
3. **Give the user the link.** One link is the whole package: the receiving side opens it to see the work, step by step, each step carrying its verifiable receipt. A client viewing the link can accept the work or flag a problem with it.
4. **In the receiving AI, call `handover_accept`** with the handover id to pick up. Pickup restores the context so work continues where it left off. Pickup is always free and never counts against any allowance.
5. **Check state when needed** with `handover_status` (where a handover stands, including client acceptance) or `handover_list` (recent handovers).

## Costs, stated plainly

- Free every day: 20 calls + 1 wrap-up free every day; picking up in another AI is always free. The wrap-up is the `handover` call.
- Pickup (`handover_accept`) is always free, in any AI, for the sender and for a different recipient alike.
- If the free wrap-up is used up, a Day Pass is $0.99 for 24 hours of unlimited use. Agents may pay it themselves in USDC on Base via x402; humans check out at https://zambo.dev/day-pass. A Zambo Pass is $29 for 30 days ($290 for a year, $19 for eligible token holders).

## What to promise, and what not to promise

- A handover proves what was saved and carried: the steps, their results, and their receipts, unchanged since they were recorded.
- It does not prove the work was correct. Never tell a user or a client that a handover or a receipt proves an answer was right.
- The correct term is "verifiable receipt". Use it.
- If a client disputes the work, the handover record is the shared evidence both sides can inspect. Point to the record, not to your own summary of it.

## Example exchanges

- User: "I need to continue this in Claude." You: save the key facts, call `handover`, return the link, and tell the user to open Claude, connect Zambo, and pick it up. Mention that pickup is free.
- User: "Send this analysis to my client with proof." You: wrap it up, return the link, and explain the client can open it, see every step with its receipt, and accept or flag it.
- User (in a fresh session): "Pick up the handover I made earlier." You: ask for the id or link if you do not have it, call `handover_accept`, confirm what was restored, and continue the work.
