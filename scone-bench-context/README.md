# SCONE-bench Context

## What is SCONE-bench?

SCONE-bench is Anthropic's benchmark for evaluating AI offensive capability
against smart contracts. Published November 2025.

- 405 real deployed smart contracts that were later exploited
- AI agents scored by simulated dollar value of funds stolen
- 55.88% attack success rate on post-knowledge-cutoff contracts
- Exploit revenue doubled every 1.3 months (Jan–Nov 2025)
- AI found 2 novel zero-day vulnerabilities in 2,849 fresh contracts

Key insight: testing on post-knowledge-cutoff contracts proves the AI is
reasoning about vulnerabilities, not memorizing known exploits.

## The Gap This Repo Fills

SCONE-bench proved AI can find and exploit vulnerabilities (offensive).

Nobody has yet built the defensive equivalent — proving AI can fix
them, using the same measurement methodology.

This repo is the beginning of that defensive equivalent:
- Same contracts
- Same infrastructure concept
- But measuring: can the AI fix what it finds?

## The Closed Loop

SCONE-bench open loop:
AI finds vulnerability → AI exploits it → score recorded

This repo proposed closed loop:
AI finds vulnerability → AI suggests fix → developer applies fix →
offensive agent re-tests → pass = offensive agent can no longer extract funds

## Research Question

Can iterative AI-assisted remediation loops —
audit, fix, re-audit — systematically close smart contract vulnerabilities
without the AI ever generating working exploits, and do current LLMs
reliably detect second-order vulnerabilities introduced by developer fixes?
