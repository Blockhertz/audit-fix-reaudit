# Audit Score Observations

## Run 1 — 12 November 2026
Contract: FixedToken_v2.sol (Round 3 — Final Safe Version)
Score: 35 / 100
Tool: Blockhertz AI Smart Contract Auditor

## Run 2 — 20 November 2026
Contract: FixedToken_v2.sol (identical code, no changes)
Score: 15 / 100
Tool: Blockhertz AI Smart Contract Auditor

## Observation
20-point score variance on identical input. Expected LLM behavior (temperature > 0).

## Research Implication
Score-based re-audit loops are insufficient for verifying a fix. The only reliable
test is re-running the offensive agent and confirming it can no longer extract funds.
