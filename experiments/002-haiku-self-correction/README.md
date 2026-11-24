# Experiment 002 — Haiku Self-Correction via Forced Trace

## Research Question

Can a cheaper model (Haiku 4.5) fix its own false positive if forced 
to reason step by step — and does the next generation (Haiku 5.5) 
eliminate the false positive entirely?

## Background

During the iterative loop experiment (loop-001-solidity-sonnet), a 
question emerged: what happens if a cheaper model audits the same 
contract? Experiment 001 showed Haiku 4.5 produced a CRITICAL false 
positive on a Vyper contract that Sonnet 4.6 and Opus 4.7 passed 
cleanly. Experiment 002 investigates whether that failure is a 
reasoning depth problem (capability ceiling) or a reasoning effort 
problem (fixable with a better prompt).

## Contract

Same Vyper contract used in Experiment 001.
See: `contract.vy`

Built-in protections present:
- `@nonreentrant("withdraw")` — Vyper's native reentrancy lock
- Correct CEI order — state updated before external call
- Built-in overflow/underflow protection

## Methodology

Three rounds on the same contract, one variable changed per round:

| Round | Model | Prompt Strategy | Variable Changed |
|-------|-------|----------------|-----------------|
| 1 | claude-haiku-4-5-20251001 | Cold audit | Baseline |
| 2 | claude-haiku-4-5-20251001 | Forced line-by-line trace | Prompt strategy |
| 3 | claude-haiku-5-5 | Cold audit | Model generation |

Model status at time of experiment:
- `claude-haiku-4-5-20251001` — Active (confirmed via Anthropic API, 
  retirement date no sooner than October 2026, extended per Anthropic 
  deprecation policy)
- `claude-haiku-5-5` — Active

All audits run through Blockhertz AI Auditor 
(blockhertz.com/tools/ai-auditor) using the production system prompt 
`buildAuditorSystemPrompt('Vyper')` from rebuild/v2 repo.

## Results

| Round | Model | riskScore | CRITICAL | Reentrancy FP | Key Finding |
|-------|-------|-----------|----------|---------------|-------------|
| 1 | Haiku 4.5 | 75 | 1 | ✅ Yes | False positive — ignored @nonreentrant |
| 2 | Haiku 4.5 | 45 | 0 | ❌ No | Self-corrected via forced trace |
| 3 | Haiku 5.5 | 35 | 0 | ❌ No | No false positive — generation improvement |

Full results: `results/`

## Key Findings

**1. Reasoning effort gap, not reasoning depth gap**
Haiku 4.5 knew the CEI rules and understood @nonreentrant — it simply 
did not apply them carefully in a single pass. When forced to trace 
execution line by line, it self-corrected completely. This suggests 
the failure is a reasoning effort problem, fixable with prompt 
engineering, not a hard capability ceiling.

**2. Generation improvement confirmed**
Haiku 5.5 did not require a forced trace prompt. It correctly 
identified @nonreentrant and CEI compliance on the first pass — 
suggesting Anthropic's training improvements between generations 
internalized the reasoning effort that previously had to be injected 
via prompt.

**3. Implication for iterative loop design**
A model with reasoning effort gaps does not just miss vulnerabilities 
— it corrupts the entire loop with false positives. Model selection 
is therefore a prerequisite measurement for reliable iterative 
audit-fix-reaudit loops, not an afterthought.

## Prompts

See `prompts/` folder in repo root:
- `exp-002-round-1-cold-audit.txt`
- `exp-002-round-2-forced-trace.txt`
- `exp-002-round-3-cold-audit.txt`

## Relationship to SCONE-bench

SCONE-bench (Anthropic, 2026) measures offensive AI capability — 
whether AI agents can exploit smart contract vulnerabilities. This 
experiment contributes to the defensive counterpart — measuring 
whether AI can reliably identify and avoid false positives, a 
prerequisite for trustworthy automated auditing.

## Future Work

- Experiment 003 — exploit validation: verify whether AI-suggested 
fixes in the iterative loop actually prevent working exploits in a 
simulated environment, using Foundry fork testing methodology similar 
to SCONE-bench.
