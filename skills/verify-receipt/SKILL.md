---
name: verify-receipt
description: Check a Zambo receipt and explain what its verdict means. Use when the user asks you to prove an AI did the work, verify or check a receipt, pastes a receipt id or a zambo.dev/run link, doubts a result an AI produced, needs evidence for a client dispute, or says things like "show me the receipt", "prove it", "did that really happen", "check this receipt", or "how do I know the AI actually did that". Also use before citing any Zambo result as evidence.
---

# Verify a Zambo receipt

Every Zambo tool call issues a verifiable receipt: a saved record of the call that anyone can recheck later. This skill teaches you to fetch the verdict and, just as important, to state exactly what the verdict does and does not establish.

## Where receipts come from

- Calling any tool on the Zambo MCP server (https://zambo.dev/mcp) returns a receipt id for that call.
- The human-readable page for a receipt is https://zambo.dev/run/<receipt-id>.
- The public verify page is https://zambo.dev/verify/.

## How to verify

Call the verify endpoint. No key or signup is needed:

```
GET https://zambo.dev/api/v2/receipt/<receipt-id>/verify
```

Read these fields in the JSON response:

- `verification_status`: the verdict. The value to look for is `verified`.
- `checks`: the individual checks, including `commitment_matches`, `canonical_payload_matches`, `provenance_binding`, and `metadata_binding`. A `pass` means that part of the saved record recomputed exactly. Hosted receipts can show some checks (for example signature or chain checks) as `not_checked`; report that honestly rather than rounding it up.
- `evidence_status`: a separate statement about the captured evidence behind the result. Fresh receipts read `ok`. Some older receipts read `upstream_error`, because the upstream service returned an error body that was captured as the evidence; those records are labeled that way on purpose. A receipt can be `verified` for its saved record while its evidence status still tells you the underlying capture was an error response.

If the id does not resolve, say so plainly. Never report a receipt as verified unless the endpoint returns `verification_status` of `verified` for that exact id.

## What "verified" means

- The saved result was not changed after it was saved. The record you are looking at now recomputes to the record that was issued at call time.
- The receipt binds the result to its provenance: which tool ran, when, and what it returned.

## What "verified" does not mean

- It does not mean the answer was right. A wrong price, a bad summary, or a flawed analysis can sit inside a perfectly verified receipt. Verification covers the record, not the truth of its contents.
- It does not mean the underlying source was reliable. Check `evidence_status` and the receipt's own detail for what was captured.
- Never upgrade the claim. Do not say a result is proven correct or beyond dispute because its receipt verified.

## The standard behind it

Zambo receipts follow AER-1, an IETF Internet-Draft (draft-zambo-aer1-26) that defines the receipt format so other implementations can issue and check the same records. A public conformance corpus of 126 test vectors and 129 checks is published at https://zambo.dev/aer1/corpus.json, so anyone can test an independent verifier against the same cases. When a user asks why they should trust the format, point to the draft and the corpus, not to Zambo's say-so.

## Language to use

- Say "verifiable receipt".
- Say: "The receipt verifies, which means the saved record was not changed after the call. It does not by itself prove the answer was right."
- When evidence is weak or an evidence status is not `ok`, name that gap in the same breath as the verdict.
