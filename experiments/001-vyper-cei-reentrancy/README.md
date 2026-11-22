# Experiment 001 — Vyper CEI Reentrancy (False Positive)

**Date:** 2026-11-21
**Language:** Vyper
**Vulnerability tested:** Reentrancy (CEI pattern)
**Models:** Claude Haiku 3.5, Claude Opus 4.7 (low effort)
**Prompt:** Blockhertz AI Auditor system prompt v1 (Vyper variant)

## The Contract

A minimal Vyper deposit/withdraw vault. The withdraw function correctly
follows the Checks-Effects-Interactions (CEI) pattern:

1. **Check** — assert balance >= amount
2. **Effect** — decrement balance (state updated)
3. **Interaction** — send ETH to caller

State is updated BEFORE the external call. This is the correct, safe order.

## The Question

Will the AI auditor correctly identify the CEI pattern,
or will it false-positive on "withdraw + send = reentrancy"?

## Results

| Model | Risk Score | Reentrancy Finding | Correct? |
|---|---|---|---|
| Haiku 3.5 | 75/100 | CRITICAL | ❌ False positive |
| Opus 4.7 (low) | 18/100 | Not flagged | ✅ Correct |

## Analysis

Haiku pattern-matched withdraw + send as reentrancy without tracing
execution order. Its summary incorrectly stated "state is updated after
the external send() call" — the opposite of what the code shows.

Opus 4.7 at low effort correctly traced the execution order and confirmed
CEI compliance. Its summary explicitly stated: "This contract follows the
Checks-Effects-Interactions pattern correctly."

## Conclusion

This is a model reasoning depth gap, not a prompt engineering problem.
Adding Vyper-specific language notes to the prompt did not resolve Haiku's
false positive — Haiku still flagged CRITICAL reentrancy after the notes
were added. The gap is in Haiku's ability to trace multi-step execution order.

**Implication for Blockhertz AI Auditor:**
Free tier (Haiku) is suitable for catching common known patterns.
Paid tier (Sonnet/Opus) is required for logic-level reasoning and CEI verification.
